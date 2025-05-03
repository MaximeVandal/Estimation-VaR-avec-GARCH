## Description

Ce projet a été réalisé dans le cadre du cours **MATH60633** à HEC Montréal.  
L’objectif principal est d’estimer et de backtester la **Value at Risk (VaR)** d’un portefeuille composé de deux indices financiers à l’aide d’un modèle **GARCH(1,1) avec erreurs normales**.

## Objectifs du projet

- Estimer un modèle GARCH(1,1).
- Prévoir la volatilité et la VaR d’un portefeuille.
- Réaliser un backtest de la VaR sur données réelles.
- Automatiser l’exécution du projet avec une structure claire et indépendante de la plateforme.

## Structure du projet

- `Code/` → Contient le script R principal du projet `Main.R`  
- `data/` → Contient les données financière (`indices.rda`)  
- `Function/` → Contient le script R des fonctions utilisés, incluant `f_forecast_var.R`  
- `output/` → Contient les sorties du script (`.rda`, `.png`)  
- `README/` → Consignes du projet
- `Presentation.Rmd` → RMarkdown pour présenter le travail

## Méthodologie

1. Charger les données depuis janvier 2005.
2. Calculer les rendements logarithmiques des deux indices.
3. Estimer un modèle GARCH(1,1) sur les 1000 premières observations.
4. Prévoir la VaR à 95 % et identifier l’indice le plus risqué.
5. Réaliser un backtest en utilisant une fenêtre glissante sur 1000 jours.
6. Générer des graphiques comparant rendements réalisés et VaR.
7. Sauvegarder les résultats du backtest.
8. Générer un fichier RMarkdown pour présenter le travail et les résultats.

## Auteurs

- [Faycal Berrada]
- [Jérémy Lagacé]
- [Maxime Levasseur-Vandal]
