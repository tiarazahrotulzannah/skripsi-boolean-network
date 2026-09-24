# skripsi-boolean-network
1. Analisis Jaringan Boolean pada Kanker Payudara HER2-Positif
2. Gambaran Umum
Repositori ini memuat alur kerja dan skrip analisis untuk
analisis jaringan Boolean terhadap empat gen kunci yang terkait dengan
kanker payudara HER2-positif:
- IRF1
- E2F1
- MYC
- BHLHE40

3. Alur Kerja
1. Memperoleh data ekspresi gen
2. Mengubah data ekspresi gen menjadi format biner
3. Mengidentifikasi hubungan regulasi
4. Menyusun aturan Boolean
5. Memilih 10 sampel pasien
6. Menentukan keadaan awal
7. Membangun jaringan Boolean
8. Mengidentifikasi atraktor jaringan
9. Mensimulasikan lintasan pasien
10. Menganalisis keadaan atraktor
11. Memvisualisasikan distribusi atraktor

4.Jaringan Boolean
Hubungan regulasi yang digunakan dalam jaringan Boolean adalah:

IRF1 ─| E2F1 ─→ MYC

BHLHE40 dimodelkan sebagai simpul independen.

Aturan Boolean-nya adalah:

IRF1 = IRF1
E2F1 = NOT IRF1
MYC = E2F1
BHLHE40 = BHLHE40

5. Analisis Atraktor

Jaringan Boolean dianalisis menggunakan pembaruan sinkron
untuk mengidentifikasi kemungkinan keadaan atraktor.

Keadaan awal spesifik pasien kemudian disimulasikan untuk
menentukan atraktor yang dicapai oleh setiap pasien yang dipilih.

6. Visualisasi

Analisis ini menghasilkan:

- Plot batang frekuensi atraktor
- Plot titik keadaan atraktor

Plot batang menunjukkan jumlah pasien yang terkait dengan
setiap keadaan atraktor.

Plot titik menunjukkan keadaan akhir ON/OFF setiap gen untuk
setiap sampel pasien.


attractor_bar_plot.png
attractor_dot_plot.png 
