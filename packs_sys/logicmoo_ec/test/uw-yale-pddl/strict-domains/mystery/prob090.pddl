(DEFINE (PROBLEM MYSTY-A-8)
   (:DOMAIN MYSTERY-TYPED)
   (:OBJECTS SHRIMP HAM SCALLION RICE HOTDOG YOGURT CHICKEN KALE
             SNICKERS - FOOD
             ENTERTAINMENT AESTHETICS STIMULATION - PLEASURE
             GRIEF LACERATION SCIATICA LONELINESS PROSTATITIS ANGER
             ANGINA - PAIN
             GUANABARA KENTUCKY BAVARIA BOSNIA - PROVINCE
             JUPITER SATURN - PLANET)
   (:INIT (EATS SCALLION RICE)
          (EATS KALE SNICKERS)
          (LOCALE RICE BOSNIA)
          (CRAVES ENTERTAINMENT HAM)
          (EATS RICE SCALLION)
          (EATS KALE CHICKEN)
          (CRAVES AESTHETICS SCALLION)
          (HARMONY AESTHETICS SATURN)
          (EATS SNICKERS HAM)
          (CRAVES GRIEF SHRIMP)
          (ORBITS JUPITER SATURN)
          (CRAVES SCIATICA HOTDOG)
          (CRAVES ANGINA SNICKERS)
          (EATS KALE YOGURT)
          (EATS HAM SCALLION)
          (LOCALE SCALLION BOSNIA)
          (EATS SHRIMP HAM)
          (CRAVES LACERATION SCALLION)
          (EATS SHRIMP RICE)
          (CRAVES PROSTATITIS CHICKEN)
          (EATS SNICKERS KALE)
          (ATTACKS KENTUCKY BAVARIA)
          (EATS RICE SHRIMP)
          (EATS SNICKERS HOTDOG)
          (EATS CHICKEN YOGURT)
          (LOCALE HOTDOG BOSNIA)
          (HARMONY ENTERTAINMENT SATURN)
          (EATS YOGURT CHICKEN)
          (LOCALE YOGURT BOSNIA)
          (LOCALE CHICKEN BAVARIA)
          (EATS HAM RICE)
          (HARMONY STIMULATION SATURN)
          (EATS YOGURT HOTDOG)
          (EATS RICE HAM)
          (EATS HAM SNICKERS)
          (EATS HAM SHRIMP)
          (CRAVES STIMULATION SNICKERS)
          (ATTACKS BAVARIA BOSNIA)
          (EATS SCALLION HAM)
          (EATS YOGURT KALE)
          (LOCALE KALE KENTUCKY)
          (CRAVES LONELINESS YOGURT)
          (ATTACKS GUANABARA KENTUCKY)
          (EATS CHICKEN KALE)
          (CRAVES ANGER KALE)
          (LOCALE SHRIMP BAVARIA)
          (EATS KALE HOTDOG)
          (EATS HOTDOG KALE)
          (LOCALE SNICKERS GUANABARA)
          (EATS HOTDOG SNICKERS)
          (LOCALE HAM BOSNIA)
          (EATS HOTDOG YOGURT))
   (:GOAL (AND (CRAVES LACERATION KALE))))