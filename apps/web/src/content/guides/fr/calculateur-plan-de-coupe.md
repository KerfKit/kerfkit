---
key: "cutting-calculator"
reviewed: true
title: "Calculateur de plan de coupe : tirez plus de pièces de chaque panneau"
description: "Comment travaille un optimiseur de découpe, ce que le trait de scie change vraiment, et comment débiter un panneau de 2500 × 1220 sans prise de tête."
date: "2026-07-04"
---

Vous avez une liste de pièces à débiter et un panneau qui a coûté de vrais euros. Devant le rayon panneaux, la question est toujours la même : *est-ce que tout tient sur un panneau, ou il m'en faut un deuxième ?*

On peut répondre au crayon, sur du papier quadrillé, en vingt minutes de croquis. On l'a tous fait pendant des années — jusqu'au trait de scie oublié, ou à la porte qu'on ne peut pas tourner à cause du fil du bois. Résultat : une pièce manquante et un aller-retour au négoce.

Un calculateur de découpe fait le même croquis en quelques millisecondes. Et il n'oublie jamais le trait de scie.

## Ce que fait vraiment un optimiseur de découpe

Le cœur du problème s'appelle le *placement en deux dimensions* : poser des rectangles (vos pièces) sur un grand rectangle (votre panneau) en perdant le moins de matière possible. Ça a l'air simple ; ça ne l'est notoirement pas — le nombre d'arrangements possibles explose bien avant d'arriver à un caisson complet. C'est exactement pour ça que « je fais ça au jugé » finit par coûter des panneaux.

Un bon calculateur gère quatre choses en même temps :

1. **Le placement.** Où va chaque pièce, pour que le nombre de panneaux reste minimal.
2. **Le trait de scie.** Chaque passage de lame mange sa largeur de matière. Deux pièces ne partagent jamais une arête — il y a un trait entre elles, à chaque fois. L'ignorer, c'est sortir des pièces trop courtes.
3. **Le fil du bois.** Un côté visible dont le fil doit rester vertical ne se tourne pas de 90° sous prétexte qu'il se range mieux. Il faut un verrou de rotation par pièce.
4. **L'ordre des coupes.** Sur scie sur table ou scie plongeante, il faut des coupes *traversantes*, de rive à rive. Un placement que seule une CNC peut suivre ne sert à rien dans un atelier.

Si l'outil respecte ces quatre points, le plan qu'il imprime se découpe vraiment, debout devant la scie.

## Le trait de scie compte plus que vous ne pensez

Un exemple classique : des façades de tiroir de 396 mm dans une longueur de 2500 mm. Sans trait, 2500 ÷ 396 promet six façades, avec de la marge. Avec une lame de 3 mm : 6 × 396 + 5 × 3 = 2391 mm — ça passe encore, mais la « marge » a fondu de 124 à 109 mm. Passez les façades à 415 mm : le papier promet toujours six ; la scie en livre cinq et une chute. Tout le piège est là : le papier dit oui, la lame dit non.

## Les formats de panneaux en France

Au négoce, le contreplaqué et le mélaminé se trouvent souvent en **2500 × 1220 mm**, et le mélaminé grand format en 2800 × 2070 mm. Donnez au calculateur votre vrai format — pas le « 4×8 » nord-américain (2440 × 1220). Et pensez à la recoupe de rive : les chants d'usine sont rarement droits, les coins prennent des coups au transport ; 5 à 10 mm de recoupe par rive, c'est l'habitude de beaucoup d'ateliers.

## Lire un plan de coupe

Un bon schéma de débit vous dit d'un coup d'œil :

- **Quelles pièces partagent un panneau** — vous savez combien de panneaux acheter avant le premier coup de scie.
- **Le pourcentage de chutes.** Servez-vous-en pour comparer des plans, pas pour courir après un chiffre magique : un projet plein de façades au fil imposé perdra toujours plus qu'une pile de tablettes.
- **Les marques de rotation** sur les pièces que l'optimiseur a tournées. Si le fil devait rester droit, verrouillez et relancez.
- **Le nombre de coupes.** Moins de coupes, c'est moins de temps à la scie et moins d'occasions de dévier du trait.

## À la main ou à la machine ?

Le tracé à la main garde un vrai avantage : on réfléchit à chaque pièce en la dessinant, l'ordre des coupes vient tout seul. Pour le projet du week-end à trois pièces, continuez comme ça.

Dès qu'on dépasse une poignée de pièces, la balance s'inverse. Le logiciel essaie des arrangements que vous ne dessineriez jamais, applique le trait de scie parfaitement à chaque fois, et replanifie tout le panneau dès qu'une cote change. Quand le client passe le caisson de 600 à 650, la différence entre redessiner et retaper un chiffre, c'est votre soirée.

## Essayez avec votre propre liste

Le calculateur ci-dessous fait tourner exactement le même moteur que notre app iOS — même code, compilé pour votre navigateur, entièrement hors ligne. Un panneau, jusqu'à vingt pièces, trait de scie et fil du bois compris. Tapez vos pièces et regardez le plan se redessiner pendant que vous écrivez.

**[Ouvrir le calculateur de coupe gratuit →](/fr/lite)**

Pas de compte, pas d'envoi — votre liste de débit ne quitte pas la page.
