(DEFINE (PROBLEM LOGISTICS2)
   (:DOMAIN LOGISTICS-ADL)
   (:OBJECTS PACKAGE1 PACKAGE2 PACKAGE3 PACKAGE5 PACKAGE7 - OBJ
             PGH-TRUCK BOS-TRUCK LA-TRUCK NY-TRUCK - TRUCK
             AIRPLANE1 AIRPLANE2 - AIRPLANE
             BOS-PO LA-PO PGH-PO NY-PO - LOCATION
             BOS-AIRPORT PGH-AIRPORT LA-AIRPORT NY-AIRPORT - AIRPORT
             PGH BOS LA NY - CITY)
   (:INIT (AT PACKAGE1 PGH-PO)
          (AT PACKAGE2 PGH-PO)
          (AT PACKAGE3 PGH-PO)
          (AT PACKAGE5 BOS-PO)
          (AT PACKAGE7 NY-PO)
          (AT AIRPLANE1 PGH-AIRPORT)
          (AT AIRPLANE2 PGH-AIRPORT)
          (AT BOS-TRUCK BOS-PO)
          (AT PGH-TRUCK PGH-PO)
          (AT LA-TRUCK LA-PO)
          (AT NY-TRUCK NY-PO)
          (LOC-AT PGH-PO PGH)
          (LOC-AT PGH-AIRPORT PGH)
          (LOC-AT BOS-PO BOS)
          (LOC-AT BOS-AIRPORT BOS)
          (LOC-AT LA-PO LA)
          (LOC-AT LA-AIRPORT LA)
          (LOC-AT NY-PO NY)
          (LOC-AT NY-AIRPORT NY))
   (:GOAL (AND (AT PACKAGE1 BOS-PO)
               (AT PACKAGE2 NY-PO)
               (AT PACKAGE3 LA-PO)
               (AT PACKAGE5 PGH-PO)
               (AT PACKAGE7 PGH-PO))))