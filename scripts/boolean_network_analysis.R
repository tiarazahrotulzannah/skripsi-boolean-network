  2. Baca file hasil binarisasi  
file_input <- "C:/Users/ASUS/Downloads/hasil binarisasi BASC-B.xlsx" 
data_bin <- read_excel(file_input) 
# Lihat ukuran data 
dim(data_bin) 
# Lihat nama kolom 
colnames(data_bin) 
# Lihat beberapa baris 
head(data_bin) 
data_gen <- data_bin[, c( 
"Sample", 
"E2F1", 
"IRF1", 
"MYC", 
"BHLHE40" 
)] 
# Hapus data yang tidak lengkap 
data_gen <- data_gen[ 
complete.cases(data_gen), 
] 
cat("Jumlah pasien setelah filtering:", nrow(data_gen), "\n") 
3. Membuat state masing-masing pasien 
data_gen$State <- paste0( 
data_gen$E2F1, 
data_gen$IRF1, 
data_gen$MYC, 
data_gen$BHLHE40 
) 
cat("\nDistribusi state seluruh pasien:\n") 
print(table(data_gen$State)) 
4. Pilih 10 pasien secara random tetapi tetap beragam 
# Ambil maksimal satu pasien dari setiap state 
pilihan <- do.call( 
rbind, 
lapply( 
split(data_gen, data_gen$State), 
function(x) { 
x[sample(nrow(x), 1), ] 
} 
) 
) 
# Kalau state > 10, pilih 10 state secara random 
if (nrow(pilihan) > 10) { 
pilihan <- pilihan[ 
sample(1:nrow(pilihan), 10), 
] 
} 
# Acak urutan pasien 
pilihan <- pilihan[ 
sample(1:nrow(pilihan)), 
] 
# Reset row names 
rownames(pilihan) <- NULL 
cat("\n====================================\n") 
cat("10 PASIEN YANG DIGUNAKAN\n") 
cat("====================================\n\n") 
print( 
pilihan[, c( 
"Sample", 
"E2F1", 
"IRF1", 
"MYC", 
"BHLHE40", 
"State" 
)] 
) 
5.Buat file initial state 
initial_states_file <-  
"C:/Users/ASUS/Downloads/INITIAL STATES 10 PASIEN.xlsx" 
write.xlsx( 
pilihan, 
initial_states_file, 
rowNames = FALSE, 
overwrite = TRUE 
) 
cat( 
"\nInitial states disimpan di:\n", 
initial_states_file, 
"\n" 
) 
6. Buat Boolean network 
network_file <-  
"C:/Users/ASUS/Downloads/BOOLEAN NETWORK IRF1 E2F1 MYC BHLHE40.txt" 
network_rules <- c( 
"targets, factors", 
"IRF1, IRF1", 
"E2F1, !IRF1", 
"MYC, E2F1", 
"BHLHE40, BHLHE40" 
) 
writeLines( 
network_rules, 
network_file 
) 
cat( 
"\nFile Boolean network dibuat:\n", 
network_file, 
"\n" 
) 
Kemudian baca dengan BoolNet: 
network <- loadNetwork(network_file) 
print(network) 
7. Cek topology network 
plotNetworkWiring(network) 
8. Ubah 10 pasien menjadi initial states 
9. Cari attractor dari seluruh network 
10. Lihat attractor BoolNet secara visual 
11. Simulasikan masing-masing pasien menuju attractor 
12. Tentukan attractor masing-masing pasien 
library(dplyr) 
library(BoolNet) 
library(openxlsx) 
# ========================================== 
# 8. UBAH 10 PASIEN MENJADI INITIAL STATES 
# ========================================== 
# Pastikan urutan gen sesuai network: IRF1, E2F1, MYC, BHLHE40 
initial_matrix <- as.matrix( 
pilihan[, c( 
"IRF1", 
"E2F1", 
"MYC", 
"BHLHE40" 
)] 
) 
storage.mode(initial_matrix) <- "numeric" 
rownames(initial_matrix) <- pilihan$Sample 
cat("\nInitial State Matrix:\n") 
print(initial_matrix) 
# ========================================== 
# 9. CARI ATTRACTOR DARI SELURUH NETWORK (EXHAUSTIVE) 
# ========================================== 
attractors <- getAttractors( 
network, 
type = "synchronous", 
method = "exhaustive", 
returnTable = TRUE 
) 
cat("\nGlobal Attractors:\n") 
print(attractors) 
# ========================================== 
# 11. SIMULASIKAN MASING-MASING PASIEN MENUJU ATTRACTOR 
# ========================================== 
simulate_to_attractor <- function(network, initial_state, max_steps = 20) { 
state <- as.numeric(initial_state) 
  history <- list() 
   
  for (step in 0:max_steps) { 
    state_key <- paste(state, collapse = "") 
     
    if (state_key %in% names(history)) { 
      break 
    } 
     
    history[[state_key]] <- state 
     
    next_state <- stateTransition( 
      network, 
      state, 
      type = "synchronous" 
    ) 
    state <- next_state 
  } 
   
  return( 
    data.frame( 
      Step = 0:(length(history)-1), 
      State = names(history) 
    ) 
) 
} 
simulation_results <- list() 
for (i in 1:nrow(initial_matrix)) { 
sample_name <- rownames(initial_matrix)[i] 
result <- simulate_to_attractor( 
network, 
initial_matrix[i, ], 
max_steps = 20 
) 
result$Sample <- sample_name 
simulation_results[[sample_name]] <- result 
} 
simulation_all <- do.call(rbind, simulation_results) 
rownames(simulation_all) <- NULL 
# ========================================== 
# 12. TENTUKAN ATTRACTOR MASING-MASING PASIEN 
# ========================================== 
attractor_patient <- do.call( 
  rbind, 
  lapply( 
    names(simulation_results), 
    function(sample_name) { 
      result <- simulation_results[[sample_name]] 
      last_state <- result$State[nrow(result)] 
       
      data.frame( 
        Sample = sample_name, 
        Attractor = last_state 
      ) 
    } 
  ) 
) 
 
rownames(attractor_patient) <- NULL 
 
cat("\nAttractor per Pasien:\n") 
print(attractor_patient) 
 
 
 
 
13. Gabungkan initial state + attractor 
14. Pecah attractor menjadi masing-masing gen 
15. Simpan hasil attractor ke Excel 
16. Buat tabel frekuensi attractor 
17. BAR PLOT attractor 
18. DOT PLOT / STATE MATRIX 
# ========================================== 
# 13. GABUNGKAN INITIAL STATE + ATTRACTOR 
# ========================================== 
hasil_attractor <- merge( 
pilihan[, c( 
"Sample", 
"E2F1", 
"IRF1", 
"MYC", 
"BHLHE40", 
"State" 
)], 
attractor_patient, 
by = "Sample" 
) 
cat("\nTabel Gabungan Initial State & Attractor:\n") 
print(hasil_attractor) 
# ========================================== 
# 14. PECAH ATTRACTOR MENJADI MASING-MASING GEN 
# Urutan gen di string attractor: IRF1, E2F1, MYC, BHLHE40 
# ========================================== 
hasil_attractor$Attractor_IRF1    <- substr(hasil_attractor$Attractor, 1, 1) 
hasil_attractor$Attractor_E2F1    <- substr(hasil_attractor$Attractor, 2, 2) 
hasil_attractor$Attractor_MYC     
<- substr(hasil_attractor$Attractor, 3, 3) 
hasil_attractor$Attractor_BHLHE40 <- substr(hasil_attractor$Attractor, 4, 4) 
# ========================================== 
# 15. SIMPAN HASIL ATTRACTOR KE EXCEL 
# ========================================== 
attractor_file <- "C:/Users/ASUS/Downloads/HASIL ATTRACTOR BOOLEAN NETWORK.xlsx" 
write.xlsx( 
hasil_attractor, 
attractor_file, 
rowNames = FALSE, 
overwrite = TRUE 
) 
cat("\nFile Excel berhasil disimpan di:", attractor_file, "\n") 
# ========================================== 
# 16. TABEL FREKUENSI ATTRACTOR 
# ========================================== 
attractor_frequency <- as.data.frame( 
table(hasil_attractor$Attractor) 
) 
colnames(attractor_frequency) <- c("Attractor", "Frequency") 
attractor_frequency$Percentage <- (attractor_frequency$Frequency / 
sum(attractor_frequency$Frequency)) * 100 
cat("\nFrekuensi Attractor:\n") 
print(attractor_frequency) 
# ========================================== 
# 17. BAR PLOT FREKUENSI ATTRACTOR 
# ========================================== 
png("C:/Users/ASUS/Downloads/ATTRACTOR BAR PLOT.png", width = 1000, height = 700) 
barplot( 
attractor_frequency$Frequency, 
names.arg = attractor_frequency$Attractor, 
xlab = "Attractor State", 
ylab = "Number of Patients", 
main = "Distribution of Boolean Network Attractors", 
col = "steelblue", 
ylim = c(0, max(attractor_frequency$Frequency) + 1) 
) 
dev.off() 
# ========================================== 
# 18. DOT PLOT / STATE MATRIX (VISUALISASI AKHIR) 
# ========================================== 
dot_data <- hasil_attractor[, c( 
"Sample", 
"Attractor_IRF1", 
"Attractor_E2F1", 
  "Attractor_MYC", 
  "Attractor_BHLHE40" 
)] 
 
dot_matrix <- t(as.matrix(dot_data[, -1])) 
colnames(dot_matrix) <- dot_data$Sample 
rownames(dot_matrix) <- c("IRF1", "E2F1", "MYC", "BHLHE40") 
storage.mode(dot_matrix) <- "numeric" 
 
png("C:/Users/ASUS/Downloads/ATTRACTOR DOT PLOT.png", width = 1400, height = 700) 
par(mar = c(10, 6, 4, 2)) 
 
plot( 
  NA, 
  xlim = c(0.5, ncol(dot_matrix) + 0.5), 
  ylim = c(0.5, nrow(dot_matrix) + 0.5), 
  xaxt = "n", 
  yaxt = "n", 
  xlab = "", 
  ylab = "", 
  main = "Gene States in Boolean Network Attractors (Final State)" 
) 
 
axis(1, at = 1:ncol(dot_matrix), labels = colnames(dot_matrix), las = 2, cex.axis = 0.8) 
axis(2, at = 1:nrow(dot_matrix), labels = rownames(dot_matrix), las = 1) 
 
for (i in 1:nrow(dot_matrix)) { 
  for (j in 1:ncol(dot_matrix)) { 
    if (dot_matrix[i, j] == 1) { 
      points(j, i, pch = 19, cex = 2.5, col = "darkgreen") # Hijau untuk ON (1) 
    } else { 
      points(j, i, pch = 1, cex = 2.5, col = "firebrick")  # Merah/Kosong untuk OFF (0) 
    } 
  } 
} 
 
legend( 
  "topright", 
  legend = c("ON (1)", "OFF (0)"), 
  pch = c(19, 1), 
  col = c("darkgreen", "firebrick"), 
  bty = "n", 
  pt.cex = 2 
) 
dev.off() 
cat("\nSEMUA PROSES SELESAI! File Excel dan Gambar Plot (Bar & Dot Plot) sudah 
tersimpan di folder Downloads.\n")
