
# Arduino-Russian-Roulette

### Anggota Kelompok:
* Rivi Yasha Hafizhan 2306250535
* Nabiel Harits Utomo 2306267044
* Muhammad Arya Wiandra Utomo 2306218295
* Grace Yunike Margaretha Sitorus 2306267031

## Problem 
Kestabilan suhu di ruang tertutup sangat penting, terutama untuk objek atau makhluk hidup yang sensitif terhadap perubahan suhu, seperti pada inkubator bayi dan ruang penyimpanan alat elektronik. Suhu yang tidak stabil pada inkubator dapat mengganggu termoregulasi bayi prematur dan meningkatkan risiko komplikasi medis, sementara alat elektronik rentan terhadap overheating yang dapat mempercepat kerusakan dan menurunkan umur pakai komponen. Sistem pengendalian suhu konvensional yang masih manual atau tidak adaptif sering kali tidak cukup responsif terhadap perubahan kondisi secara real-time dan kurang efisien secara energi. Oleh karena itu, dibutuhkan solusi otomatis dan adaptif yang mampu menjaga suhu dengan presisi tinggi secara berkelanjutan dalam berbagai skenario lingkungan mikro.

## Solution dan Deskripsi
Di sini lah kelompok kami memberikan solusi dalam bentuk rangkaian mikrokontroller yang berfungsi untuk mendeteksi suhu sekitarnya dan secara automatis akan mengubah kecepatan kipas untuk menyesuaikan dengan kebutuhan. Solusi kami tentunya akan memberikan peningkatan dalam efisiensi penggunaan daya dalam penggunaan kipas  dalam kasus-kasus di atas. Kemudian karena ditulis dengan bahasa assembly pastinya kode ini sangatlah flexible dan lightweight sehingga banyak mikrokontroller dapat mengimplementasinya.

## Hardware Implementation
Pada proyek kali ini kami menggunakan beberapa komponen elektronik sebagai berikut:
- Arduino Uno
- Sensor DHT11
- I2C
- LCD
- Motor DC
- Kabel Jumper
- Breadboard
- LN298N (Motor Driver)
- Kipas

## Software Implementation
Software dikembangkan menggunakan Arduino IDE dalam bahasa assembly AVR yang digunakan untuk ATMega328p.
Kami membuat kode untuk membaca data dari sensor DHT11 dan motor berdasarkan kondisi suhu.
Kode ini kemudian diunggah ke Arduino Uno untuk mengatur perilaku hardware sesuai dengan input yang diterima dari sensor suhu.

Kode Assembly di atas ditulis untuk mikrokontroler ATmega328P dan berfungsi sebagai sistem monitoring suhu dan kelembaban menggunakan sensor DHT11, sekaligus mengontrol kecepatan kipas berdasarkan suhu yang dibaca. Pertama, program menginisialisasi stack pointer dan mengatur PORTD sebagai output kecuali PD7, yang digunakan untuk komunikasi dengan DHT11. Timer0 dikonfigurasi untuk menghasilkan sinyal PWM pada pin output untuk mengendalikan kecepatan kipas.

Selanjutnya, komunikasi serial UART diatur dengan baudrate 9600, yang memungkinkan pengiriman data suhu dan kelembaban ke serial monitor. Program menunggu selama 2 detik agar sensor stabil, lalu masuk ke loop utama (main_loop) yang secara berkala membaca data dari sensor DHT11. Fungsi dht11_read menangani protokol komunikasi satu-wire dengan DHT11 untuk mengambil data suhu dan kelembaban.

Setelah data diambil, fungsi send_temp_message mengirimkan nilai suhu dan kelembaban dalam bentuk ASCII melalui UART. Berdasarkan nilai suhu, kecepatan kipas dikontrol melalui register OCR0A untuk menghasilkan PWM duty cycle berbeda: lambat (<25°C), sedang (25–29°C), atau cepat (≥30°C). Delay tambahan ditambahkan antar siklus untuk memberikan waktu proses berjalan dengan stabil. Kode juga menyertakan berbagai subrutin delay untuk mendukung timing presisi yang dibutuhkan oleh protokol DHT11 dan UART. Secara keseluruhan, kode ini adalah implementasi lengkap sistem berbasis mikrokontroler yang membaca data lingkungan dan merespons secara otomatis.