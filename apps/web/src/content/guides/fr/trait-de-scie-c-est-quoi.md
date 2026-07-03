---
key: "what-is-kerf"
reviewed: true
title: "Le trait de scie : cette largeur de lame qui mange vos panneaux"
description: "Le trait de scie, c'est la matière que la lame transforme en sciure à chaque passage. Sa largeur réelle, pourquoi il ruine les calculs sur papier, et comment mesurer le vôtre."
date: "2026-07-04"
---

Le trait de scie — *kerf* en anglais — c'est la saignée que la lame laisse derrière elle : la matière qui part en sciure à chaque passage. C'est aussi la cause numéro un des listes de débit soigneusement calculées qui ne tombent pas juste.

Chaque lame a le sien. Une lame de scie sur table classique enlève environ 2,8 à 3,2 mm par coupe. Les lames fines descendent vers 2,4 mm ; les lames de scie plongeante tournent souvent à 2,2 mm. La scie à ruban prend moins ; une fraise CNC prend exactement son diamètre. Le chiffre exact est gravé sur la lame ou dans sa fiche — et c'est ce chiffre-là qu'il faut dans vos calculs, pas une estimation.

## Pourquoi le trait casse le « ça devrait passer »

Disons que vous voulez quatre bandes de 300 mm dans 1220 mm de largeur de panneau. Sur le papier : 4 × 300 = 1200, il reste 20 mm. Facile.

Maintenant visez **quatre bandes de 305 mm** : 4 × 305 = 1220 — le papier dit « pile-poil ». La scie dit autre chose : quatre bandes demandent trois coupes, soit 3 × 3 = 9 mm de sciure avec une lame de 3 mm. 1220 + 9 = ça ne passe pas ; la quatrième bande sort 9 mm trop étroite.

La règle est simple : **n pièces côte à côte demandent n − 1 traits entre elles.** Toute liste qui saute cette règle promet des pièces qui n'existent pas.

## Aide-mémoire rapide

| Scie / lame | Trait typique |
|---|---|
| Scie sur table (lame standard) | ~3 mm |
| Lame fine | ~2,4 mm |
| Scie plongeante | ~2,2 mm |
| Scie circulaire portative | ~2,5–3 mm |
| Scie à ruban | ~0,5–1 mm |
| Fraise CNC | diamètre de la fraise (6–12 mm courant) |

Ce sont des fourchettes typiques, pas des promesses — la marque et l'affûtage font varier. Prenez le tableau comme point de départ et mesurez votre lame.

## Mesurer votre trait

Cinq minutes, une chute :

1. Sciez une rainure peu profonde dans la chute — sans traverser, juste une largeur de lame.
2. Mesurez la rainure au pied à coulisse. C'est votre trait, voile de lame compris.
3. Autre méthode : tronçonnez une pièce en deux, remettez les moitiés bord à bord et mesurez de combien l'ensemble est plus court que l'original. La différence, c'est un trait.

Faites-le une fois par lame et notez le chiffre sur la boîte. Si votre scie a du voile, votre trait *réel* est plus large que celui de la fiche — la mesure le capte, la fiche non.

## Le trait et votre liste de débit

Dans un plan de panneau, le trait s'invite entre chaque paire de pièces voisines — horizontalement et verticalement. Sur un caisson complet, ça fait des dizaines de traits : facilement plus de 100 mm de matière « invisible » sur un seul panneau. Voilà pourquoi une liste qui rentrait à merveille sur papier quadrillé réclame un deuxième panneau à l'atelier.

Deux habitudes vous gardent au sec :

- **Planifiez avec votre trait mesuré,** pas une valeur par défaut. 0,8 mm d'écart par coupe se cumule vite sur un panneau.
- **Ne faites jamais confiance à une rangée qui tombe pile.** Si le calcul dit « passe exactement », ça ne passe pas — réduisez une pièce ou changez-la de rangée.

## Laissez le logiciel porter les traits

Tenir n − 1 traits sur tout un panneau, dans deux directions, tout en gérant le fil du bois : c'est précisément le genre de comptabilité pour laquelle on a inventé les ordinateurs. Notre calculateur gratuit place votre trait entre chaque paire de pièces automatiquement — tapez le chiffre de votre lame une fois, et chaque plan sort corrigé lame comprise.

**[Essayer le calculateur avec trait de scie →](/fr/lite)**

Dans votre navigateur, hors ligne — le même moteur que l'app kerfkit.
