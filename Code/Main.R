# ==== Initialisation ====
library(xts)
library(PerformanceAnalytics)
library(parallel)
library(rugarch) # Seulement pour le graphique Varplot

rm(list = ls())

# Charger les données
load("Data/indices.rda")
prices <- prices["2005/"]
rets <- diff(log(prices))[-1]


# ==== Estimation statique de la VaR ====
source("Function/f_forecast_var.R")

VaR_SP500 <- f_forecast_var(rets[1:1000,"SP500"],0.95)
VaR_FTSE <- f_forecast_var(rets[1:1000,"FTSE100"],0.95)

cat("Les VaR au temps T + 1 sont de",
            "\nS&P500 :", round(VaR_SP500$VaR_Forecast,3),
            "\nFTSE100 :", round(VaR_FTSE$VaR_Forecast,3))


#Les VaR au temps T + 1 sont de 
#S&P500 : -0.073 
#FTSE100 : -0.066
# Donc, le plus risqué est le S&P500


# ==== Backtesting ====
T <- 1000
N <- 1000  # Nombre de jours de backtesting


# création des variables avec les fenêtres roulantes

windows_SP500 <- lapply(seq_len(N), function(i) {
  rets[i:(T + i - 1),"SP500"]
})

windows_FTSE <- lapply(seq_len(N), function(i) {
  rets[i:(T + i - 1),"FTSE100"]
})


# Parallélisation des calcule des VaR pour chaque fenêtre glissante
n_cores <- detectCores()

# Code pour Windows (pas certain fonctionne pour macOS)
cl <- makeCluster(n_cores - 1)
clusterExport(cl, c("windows_SP500", "windows_FTSE", "f_forecast_var","f_nll","f_ht"))

VaR_SP500_BT <- parSapply(cl,windows_SP500, function(x) f_forecast_var(x, level = 0.95)[[1]])
VaR_FTSE_BT <- parSapply(cl, windows_FTSE, function(x) f_forecast_var(x, level = 0.95)[[1]])

stopCluster(cl)

# Ajustement des données
dates <- index(rets[(T + 1):(T + N), ])

VaR_SP500_BT <- xts(VaR_SP500_BT, order.by = dates)
colnames(VaR_SP500_BT) <- "SP500"
  
VaR_FTSE_BT <- xts(VaR_FTSE_BT, order.by = dates)
colnames(VaR_FTSE_BT) <- "FTSE100"


# ==== Affichage et enregistrement des résultas ====
repertoire <- paste0("Output/VaR_Backtesting_", Sys.Date(), ".png")
png(repertoire) # Enregistre les 2 graphiques dans un fichier .png


par(mfrow = c(2,1))

# Graphique pour S&P 500
VaRplot(alpha = 0.05, 
        actual = rets[(T + 1):(T + N), "SP500"], 
        VaR = VaR_SP500_BT)
title("Backtesting VaR - S&P500")


# Graphique pour FTSE 100
VaRplot(alpha = 0.05, 
        actual = rets[(T + 1):(T + N), "FTSE100"], 
        VaR = VaR_FTSE_BT)
title("Backtesting VaR - FTSE100")


dev.off()


# Sauvegarde des VaR du backtesting dans un fichier .rda
repertoire <- paste0("Output/VaR_Backtesting_", Sys.Date(), ".rda")
save(VaR_SP500_BT, VaR_FTSE_BT, file = repertoire)


# ==== Vérification nombre de rendements sous la VaR ====
exceptions_SP500 <- sum(rets[(T + 1):(T + N), "SP500"] <= VaR_SP500_BT)
exceptions_FTSE  <- sum(rets[(T + 1):(T + N), "FTSE100"] <= VaR_FTSE_BT)

print(paste0("Nombre d'exceptions S&P 500 : ", exceptions_SP500*100/N,"%"))
print(paste0("Nombre d'exceptions FTSE 100 : ", exceptions_FTSE*100/N,"%"))
