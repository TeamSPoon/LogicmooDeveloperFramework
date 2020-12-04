;;;;  Copyright (c) 1984, Taiichi Yuasa and Masami Hagiya.
;;;;  Copyright (c) 1990, Giuseppe Attardi.
;;;;
;;;;    This program is free software; you can redistribute it and/or
;;;;    modify it under the terms of the GNU Library General Public
;;;;    License as published by the Free Software Foundation; either
;;;;    version 2 of the License, or (at your option) any later version.
;;;;
;;;;    See file '../Copyright' for full details.
;;;;        The structure routines.


(in-package "COMMON-LISP")
(export 'defstruct)

(in-package "SYSTEM")

(proclaim '(optimize (safety 2) (space 3)))


(defun make-access-function (name conc-name type named slot-descr)
  (declare (ignore named))
  (let* ((slot-name (nth 0 slot-descr))
	 ;; (default-init (nth 1 slot-descr))
	 ;; (slot-type (nth 2 slot-descr))
	 (read-only (nth 3 slot-descr))
	 (offset (nth 4 slot-descr))
	 (access-function (intern (string-concatenate (string conc-name)
							 (string slot-name)))))
    (cond ((null type)
           ;; If TYPE is NIL,
           ;;  the slot is at the offset in the structure-body.
	   (fset access-function #'(lambda (x)
				     (sys:structure-ref x name offset))))
          ((or (eq type 'VECTOR)
               (and (consp type)
                    (eq (car type) 'VECTOR)))
	   ;; If TYPE is VECTOR or (VECTOR ... ), ELT is used.
           (fset access-function
		 #'(lambda (x) (elt x offset))))
          ((eq type 'LIST)
           ;; If TYPE is LIST, NTH is used.
	   (fset access-function
		 #'(lambda (x) (sys:list-nth offset x))))
          (t (error "~S is an illegal structure type." type)))
    (if read-only
	(progn
	  (rem-sysprop access-function 'SETF-UPDATE-FN)
	  (rem-sysprop access-function 'SETF-LAMBDA)
	  (rem-sysprop access-function 'SETF-DOCUMENTATION))
	(progn
	  ;; The following is used by the compiler to expand inline   ;; the accessor
	  (put-sysprop-r access-function (cons (or type name) offset)
		      'STRUCTURE-ACCESS)))))

(defun make-constructor (name constructor type named slot-descriptions)
  (declare (ignore named))
  (let ((slot-names
         ;; Collect the slot-names.
         (mapcar #'(lambda (x)
                     (cond ((null x)
                            ;; If the slot-description is NIL,
                            ;;  it is in the padding of initial-offset.
                            nil)
                           ((null (car x))
                            ;; If the slot name is NIL,
                            ;;  it is the structure name.
                            ;;  This is for typed structures with names.
                            (list 'QUOTE (cadr x)))
                           (t (car x))))
                 slot-descriptions))
        (keys
         ;; Make the keyword parameters.
         (mapcan #'(lambda (x)
                     (cond ((null x) nil)
                           ((null (car x)) nil)
                           ((null (cadr x)) (list (car x)))
                           (t (list (list  (car x) (cadr x))))))
                 slot-descriptions)))
    (cond ((consp constructor)
           ;; The case for a BOA constructor.
           ;; Dirty code!!
           ;; We must add an initial value for an optional parameter,
           ;;  if the default value is not specified
           ;;  in the given parameter list and yet the initial value
           ;;  is supplied in the slot description.
           (do ((a (cadr constructor) (cdr a)) (l nil) (vs nil))
               ((endp a)
                ;; Add those options that do not appear in the parameter list
                ;;  as auxiliary paramters.
                ;; The parameters are accumulated in the variable VS.
                (setq keys
                      (nreconc (cons '&aux l)
                               (mapcan #'(lambda (k)
                                           (if (member (if (atom k) k (car k))
                                                       vs)
                                               nil
                                               (list k)))
                                       keys))))
             ;; Skip until &OPTIONAL appears.
             (cond ((eq (car a) '&optional)
                    (setq l (cons '&optional l))
                    (do ((aa (cdr a) (cdr aa)) (ov) (y))
                        ((endp aa)
                         ;; Add those options that do not appear in the
                         ;;  parameter list.
                         (setq keys
                               (nreconc (cons '&aux l)
                                        (mapcan #'(lambda (k)
                                                    (if (member (if (atom k)
                                                                    k
                                                                    (car k))
                                                                vs)
                                                        nil
                                                        (list k)))
                                                keys)))
                         (return nil))
                      (when (member (car aa) lambda-list-keywords)
                            (when (eq (car aa) '&rest)
                                  ;; &REST is found.
                                  (setq l (cons '&rest l))
                                  (setq aa (cdr aa))
                                  (unless (and (not (endp aa))
                                               (symbolp (car aa)))
                                          (illegal-boa))
                                  (setq vs (cons (car aa) vs))
                                  (setq l (cons (car aa) l))
                                  (setq aa (cdr aa))
                                  (when (endp aa)
                                        (setq keys
                                              (nreconc
                                               (cons '&aux l)
                                               (mapcan
                                                #'(lambda (k)
                                                    (if (member (if (atom k)
                                                                    k
                                                                    (car k))
                                                                vs)
                                                        nil
                                                        (list k)))
                                                keys)))
                                        (return nil)))
                            ;; &AUX should follow.
                            (unless (eq (car aa) '&aux)
                                    (illegal-boa))
                            (setq l (cons '&aux l))
                            (do ((aaa (cdr aa) (cdr aaa)))
                                ((endp aaa))
                              (setq l (cons (car aaa) l))
                              (cond ((and (atom (car aaa))
                                          (symbolp (car aaa)))
                                     (setq vs (cons (car aaa) vs)))
                                    ((and (symbolp (caar aaa))
                                          (or (endp (cdar aaa))
                                              (endp (cddar aaa))))
                                     (setq vs (cons (caar aaa) vs)))
                                    (t (illegal-boa))))
                            ;; End of the parameter list.
                            (setq keys
                                  (nreconc l
                                           (mapcan
                                            #'(lambda (k)
                                                (if (member (if (atom k)
                                                                k
                                                                (car k))
                                                            vs)
                                                    nil
                                                    (list k)))
                                            keys)))
                            (return nil))
                      ;; Checks if the optional paramter without a default
                      ;;  value has a default value in the slot-description.
                      (if (and (cond ((atom (car aa)) (setq ov (car aa)) t)
                                     ((endp (cdar aa)) (setq ov (caar aa)) t)
                                     (t nil))
                               (setq y (member ov
                                               keys
                                               :key
                                               #'(lambda (x)
                                                   (if (consp x)
                                                       ;; With default value.
                                                       (car x))))))
                          ;; If no default value is supplied for
                          ;;  the optional parameter and yet appears
                          ;;  in KEYS with a default value,
                          ;;  then cons the pair to L,
                          (setq l (cons (car y) l))
                          ;;  otherwise cons just the parameter to L.
                          (setq l (cons (car aa) l)))
                      ;; Checks the form of the optional parameter.
                      (cond ((atom (car aa))
                             (unless (symbolp (car aa))
                                     (illegal-boa))
                             (setq vs (cons (car aa) vs)))
                            ((not (symbolp (caar aa)))
                             (illegal-boa))
                            ((or (endp (cdar aa)) (endp (cddar aa)))
                             (setq vs (cons (caar aa) vs)))
                            ((not (symbolp (caddar aa)))
                             (illegal-boa))
                            ((not (endp (cdddar aa)))
                             (illegal-boa))
                            (t
                             (setq vs (cons (caar aa) vs))
                             (setq vs (cons (caddar aa) vs)))))
                    ;; RETURN from the outside DO.
                    (return nil))
                   (t
                    (unless (symbolp (car a))
                            (illegal-boa))
                    (setq l (cons (car a) l))
                    (setq vs (cons (car a) vs)))))
           (setq constructor (car constructor)))
          (t
           ;; If not a BOA constructor, just cons &KEY.
           (setq keys (cons '&key keys))))
    (cond ((null type)
           `(defun ,constructor ,keys
	      #-CLOS
              (sys:make-structure ',name ,@slot-names)
	      #+CLOS
	      (sys:make-structure (find-class ',name) ,@slot-names)))
          ((or (eq type 'VECTOR)
               (and (consp type) (eq (car type) 'vector)))
           `(defun ,constructor ,keys
              (vector ,@slot-names)))
          ((eq type 'LIST)
           `(defun ,constructor ,keys
              (list ,@slot-names)))
          ((error "~S is an illegal structure type" type)))))



(defun illegal-boa ()
  (error "An illegal BOA constructor."))


(defun make-predicate (name type named name-offset)
  (cond ((null type)
	 #'(lambda (x)
	     (structure-subtype-p x name)))
        ((or (eq type 'VECTOR)
             (and (consp type) (eq (car type) 'VECTOR)))
         ;; The name is at the NAME-OFFSET in the vector.
         (unless named (error "The structure should be named."))
	 #'(lambda (x)
	     (and (vectorp x)
		  (> (length x) name-offset)
		  ;; AKCL has (aref (the (vector t) x).)
		  ;; which fails with strings
		  (eq (elt x name-offset) name))))
        ((eq type 'LIST)
         ;; The name is at the NAME-OFFSET in the list.
         (unless named (error "The structure should be named."))
         (if (= name-offset 0)
	     #'(lambda (x)
		 (and (consp x) (eq (car x) name)))
	     #'(lambda (x)
		 (do ((i name-offset (1- i))
		      (y x (cdr y)))
		     ((= i 0) (and (consp y) (eq (car y) name)))
		   (declare (fixnum i))
		   (unless (consp y) (return nil))))))
        ((error "~S is an illegal structure type."))))


;;; PARSE-SLOT-DESCRIPTION parses the given slot-description
;;;  and returns a list of the form:
;;;        (slot-name default-init slot-type read-only offset)

(defun parse-slot-description (slot-description offset)
  (declare (si::c-local))
  (let* (slot-name default-init slot-type read-only)
    (cond ((atom slot-description)
           (setq slot-name slot-description))
          ((endp (cdr slot-description))
           (setq slot-name (car slot-description)))
          (t
           (setq slot-name (car slot-description))
           (setq default-init (cadr slot-description))
           (do ((os (cddr slot-description) (cddr os)) (o) (v))
               ((endp os))
             (setq o (car os))
             (when (endp (cdr os))
                   (error "~S is an illegal structure slot option."
                          os))
             (setq v (cadr os))
             (case o
               (:TYPE (setq slot-type v))
               (:READ-ONLY (setq read-only v))
               (t
                (error "~S is an illegal structure slot option."
                         os))))))
    (list slot-name default-init slot-type read-only offset)))


;;; OVERWRITE-SLOT-DESCRIPTIONS overwrites the old slot-descriptions
;;;  with the new descriptions which are specified in the
;;;  :include defstruct option.
  		     
(defun overwrite-slot-descriptions (news olds)
  (declare (si::c-local))
  (when olds
      (let ((sds (member (caar olds) news :key #'car)))
        (cond (sds
               (when (and (null (cadddr (car sds)))
                          (cadddr (car olds)))
                     ;; If read-only is true in the old
                     ;;  and false in the new, signal an error.
                     (error "~S is an illegal include slot-description."
                            sds))
               (cons (list (caar sds)
                           (cadar sds)
                           (caddar sds)
                           (cadddr (car sds))
                           ;; The offset if from the old.
                           (car (cddddr (car olds))))
                     (overwrite-slot-descriptions news (cdr olds))))
              (t
               (cons (car olds)
                     (overwrite-slot-descriptions news (cdr olds))))))))




(defun define-structure (name conc-name type named slots slot-descriptions
			      copier include print-function constructors
			      offset documentation)
  (put-sysprop name 'DEFSTRUCT-FORM `(defstruct ,name ,@slots))
  (put-sysprop name 'IS-A-STRUCTURE t)
  (put-sysprop name 'STRUCTURE-SLOT-DESCRIPTIONS slot-descriptions)
  (put-sysprop name 'STRUCTURE-INCLUDE include)
  (put-sysprop name 'STRUCTURE-PRINT-FUNCTION print-function)
  (put-sysprop name 'STRUCTURE-TYPE type)
  (put-sysprop name 'STRUCTURE-NAMED named)
  (put-sysprop name 'STRUCTURE-OFFSET offset)
  (put-sysprop name 'STRUCTURE-CONSTRUCTORS constructors)
  #+clos
  (when *keep-documentation*
    (sys:set-documentation name 'STRUCTURE documentation))
  (and (consp type) (eq (car type) 'VECTOR)
       (setq type 'VECTOR))
  (dolist (x slot-descriptions)
    (and x (car x)
	 (funcall #'make-access-function name conc-name type named x)))
  (when copier
    (fset copier
	  (ecase type
	    ((NIL) #'sys::copy-structure)
	    (LIST #'copy-list)
	    (VECTOR #'copy-seq))))
  )




;;; The DEFSTRUCT macro.

(defmacro defstruct (name &rest slots)
  "Syntax: (defstruct
         {name | (name {:conc-name | (:conc-name prefix-string) |
                        :constructor | (:constructor symbol [lambda-list]) |
                        :copier | (:copier symbol) |
                        :predicate | (:predicate symbol) |
                        (:include symbol) |
                        (:print-function function) |
                        (:type {vector | (vector type) | list}) |
                        :named |
                        (:initial-offset number)}*)}
         [doc]
         {slot-name |
          (slot-name [default-value-form] {:type type | :read-only flag}*) }*
         )
Defines a structure named by NAME.  The doc-string DOC, if supplied, is saved
as a STRUCTURE doc and can be retrieved by (documentation 'NAME 'structure)."
  (let*((slot-descriptions slots)
	;;#+clos
	local-slot-descriptions
        options
        conc-name
        constructors default-constructor no-constructor
        copier
        predicate predicate-specified
        include
        print-function type named initial-offset
        offset name-offset
        documentation)

    (when (consp name)
          ;; The defstruct options are supplied.
          (setq options (cdr name))
          (setq name (car name)))

    ;; The default conc-name.
    (setq conc-name (string-concatenate (string name) "-"))

    ;; The default constructor.
    (setq default-constructor
          (intern (string-concatenate "MAKE-" (string name))))

    ;; The default copier and predicate.
    (setq copier
          (intern (string-concatenate "COPY-" (string name)))
          predicate
          (intern (string-concatenate (string name) "-P")))

    ;; Parse the defstruct options.
    (do ((os options (cdr os)) (o) (v))
        ((endp os))
      (cond ((and (consp (car os)) (not (endp (cdar os))))
             (setq o (caar os) v (cadar os))
             (case o
               (:CONC-NAME
                (if (null v)
                    (setq conc-name nil)
                    (setq conc-name v)))
               (:CONSTRUCTOR
                (if (null v)
                    (setq no-constructor t)
                    (if (endp (cddar os))
                        (setq constructors (cons v constructors))
                        (setq constructors (cons (cdar os) constructors)))))
               (:COPIER (setq copier v))
               (:PREDICATE
                (setq predicate v)
                (setq predicate-specified t))
               (:INCLUDE
                (setq include (cdar os))
                (unless (get-sysprop v 'IS-A-STRUCTURE)
                        (error "~S is an illegal included structure." v)))
               (:PRINT-FUNCTION (setq print-function v))
               (:TYPE (setq type v))
               (:INITIAL-OFFSET (setq initial-offset v))
               (t (error "~S is an illegal defstruct option." o))))
            (t
             (if (consp (car os))
                 (setq o (caar os))
                 (setq o (car os)))
             (case o
               (:CONSTRUCTOR
                (setq constructors
                      (cons default-constructor constructors)))
               ((:CONC-NAME :COPIER :PREDICATE :PRINT-FUNCTION))
               (:NAMED (setq named t))
               (t (error "~S is an illegal defstruct option." o))))))

    (setq conc-name (intern (string conc-name)))

    ;; Skip the documentation string.
    (when (and (not (endp slot-descriptions))
               (stringp (car slot-descriptions)))
          (setq documentation (car slot-descriptions))
          (setq slot-descriptions (cdr slot-descriptions)))
    
    ;; Check the include option.
    (when include
          (unless (equal type (get-sysprop (car include) 'STRUCTURE-TYPE))
                  (error "~S is an illegal structure include."
                         (car include))))

    ;; Set OFFSET.
    (setq offset (if include
		     (get-sysprop (car include) 'STRUCTURE-OFFSET)
		     0))

    ;; Increment OFFSET.
    (when (and type initial-offset)
          (setq offset (+ offset initial-offset)))
    (when (and type named)
          (setq name-offset offset)
          (setq offset (1+ offset)))

    ;; Parse slot-descriptions, incrementing OFFSET for each one.
    (do ((ds slot-descriptions (cdr ds))
         (sds nil))
        ((endp ds)
         (setq slot-descriptions (nreverse sds)))
      (push (parse-slot-description (car ds) offset) sds)
      (setq offset (1+ offset)))

    ;; If TYPE is non-NIL and structure is named,
    ;;  add the slot for the structure-name to the slot-descriptions.
    (when (and type named)
          (setq slot-descriptions
                (cons (list nil name) slot-descriptions)))

    ;; Pad the slot-descriptions with the initial-offset number of NILs.
    (when (and type initial-offset)
          (setq slot-descriptions
                (append (make-list initial-offset) slot-descriptions)))

    ;;#+clos
    (setq local-slot-descriptions slot-descriptions)

    ;; Append the slot-descriptions of the included structure.
    ;; The slot-descriptions in the include option are also counted.
    (cond ((null include))
          ((endp (cdr include))
           (setq slot-descriptions
                 (append (get-sysprop (car include) 'STRUCTURE-SLOT-DESCRIPTIONS)
                         slot-descriptions)))
          (t
           (setq slot-descriptions
                 (append (overwrite-slot-descriptions
                          (mapcar #'(lambda (sd)
                                      (parse-slot-description sd 0))
                                  (cdr include))
                          (get-sysprop (car include) 'STRUCTURE-SLOT-DESCRIPTIONS))
                         slot-descriptions))))

    (cond (no-constructor
           ;; If a constructor option is NIL,
           ;;  no constructor should have been specified.
           (when constructors
                 (error "Contradictory constructor options.")))
          ((null constructors)
           ;; If no constructor is specified,
           ;;  the default-constructor is made.
           (setq constructors (list default-constructor))))

    ;; Check the named option and set the predicate.
    (when (and type (not named))
          (when predicate-specified
                (error "~S is an illegal structure predicate."
                       predicate))
          (setq predicate nil))

    (when include (setq include (car include)))

    ;; Check the print-function.
    (when (and print-function type)
          (error "An print function is supplied to a typed structure."))

    (if (or type (not (member ':CLOS *features*)))
	`(eval-when (compile load eval)

	  (define-structure ',name ',conc-name ',type ',named ',slots
			    ',slot-descriptions ',copier ',include
			    ',print-function ',constructors ',offset
			    ',documentation)
	  ,@(mapcar #'(lambda (constructor)
			(make-constructor name constructor type named
					  slot-descriptions))
	     constructors)
	  ,@(when predicate
	      (list `(fset ',predicate
		      (make-predicate ',name ',type ',named ',name-offset))))
	  ',name)

      ;; else (and (not type) (member :CLOS *features*))

      `(eval-when (compile load eval)

	(defclass ,name (,(or include 'STRUCTURE-OBJECT))
	  ,(mapcar
	    #'(lambda (sd)
		(if sd
		    (list* (first sd)
			   :initform (second sd)
			   :initarg 
			   (intern (symbol-name (first sd))
				   (find-package 'KEYWORD))
			   (when (third sd) (list :type (third sd))))
		    nil))		; for initial offset slots
	    local-slot-descriptions)
	  (:metaclass structure-class))

#|	   (with-slots (defstruct-form slot-descriptions initial-offset
			 constructors documentation copier predicate
			 print-function)
		       (find-class ',name)
              (setq defstruct-form '(defstruct ,name ,@slots))
	      (setq slot-descriptions ',slot-descriptions)
	      (setq initial-offset ',structure-offset)
	      (setq constructors ',constructors)
	      (setq documentation ,documentation)
	      (setq copier ,copier)
	      (setq predicate ,predicate)
	      (setq print-function ,print-function))
|#

	,@(if print-function
	      `((defmethod print-object
		    ((obj ,name) stream)
		  (,print-function obj stream *print-level*))))

	(define-structure ',name ',conc-name ',type ',named ',slots
			  ',slot-descriptions ',copier ',include
			  ',print-function ',constructors ',offset
			  ',documentation)
	,@(mapcar #'(lambda (constructor)
		      (make-constructor name constructor type named
					slot-descriptions))
	   constructors)
	,@(when predicate
	    (list `(fset ',predicate
		    (make-predicate ',name ',type ',named ',name-offset))))
	',name))))


;;; The #S reader.

(defun sharp-s-reader (stream subchar arg)
  (declare (ignore subchar))
  (when (and arg (null *read-suppress*))
        (error "An extra argument was supplied for the #S readmacro."))
  (let ((l (read stream)))
    (unless (get-sysprop (car l) 'IS-A-STRUCTURE)
            (error "~S is not a structure." (car l)))
    ;; Intern keywords in the keyword package.
    (do ((ll (cdr l) (cddr ll)))
        ((endp ll)
         ;; Find an appropriate construtor.
         (do ((cs (get-sysprop (car l) 'STRUCTURE-CONSTRUCTORS) (cdr cs)))
             ((endp cs)
              (error "The structure ~S has no structure constructor."
                     (car l)))
           (when (symbolp (car cs))
                 (return (apply (car cs) (cdr l))))))
      (rplaca ll (intern (string (car ll)) 'KEYWORD)))))



;; Set the dispatch macro.
(set-dispatch-macro-character #\# #\s 'sharp-s-reader)
(set-dispatch-macro-character #\# #\S 'sharp-s-reader)


;; Examples from Common Lisp Reference Manual.

#|
(defstruct ship
  x-position
  y-position
  x-velocity
  y-velocity
  mass)

(defstruct person name age sex)

(defstruct (astronaut (:include person (age 45))
                      (:conc-name astro-))
  helmet-size
  (favorite-beverage 'tang))

(defstruct (foo (:constructor create-foo (a
                                          &optional b (c 'sea)
                                          &rest d
                                          &aux e (f 'eff))))
  a (b 'bee) c d e f)

(defstruct (binop (:type list) :named (:initial-offset 2))
  (operator '?)
  operand-1
  operand-2)

(defstruct (annotated-binop (:type list)
                            (:initial-offset 3)
                            (:include binop))
  commutative
  associative
  identity)
|#

