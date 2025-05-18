# TempShield

### Anggota Kelompok:
* Rivi Yasha Hafizhan 2306250535
* Nabiel Harits Utomo 2306267044
* Muhammad Arya Wiandra Utomo 2306218295
* Grace Yunike Margaretha Sitorus 2306267031

## Introduction to the Problem and the Solution
Kestabilan suhu di ruang tertutup sangat penting, terutama untuk objek atau makhluk hidup yang sensitif terhadap perubahan suhu, seperti pada inkubator bayi dan ruang penyimpanan alat elektronik. Suhu yang tidak stabil pada inkubator dapat mengganggu termoregulasi bayi prematur dan meningkatkan risiko komplikasi medis, sementara alat elektronik rentan terhadap overheating yang dapat mempercepat kerusakan dan menurunkan umur pakai komponen. Sistem pengendalian suhu konvensional yang masih manual atau tidak adaptif sering kali tidak cukup responsif terhadap perubahan kondisi secara real-time dan kurang efisien secara energi. Oleh karena itu, dibutuhkan solusi otomatis dan adaptif yang mampu menjaga suhu dengan presisi tinggi secara berkelanjutan dalam berbagai skenario lingkungan mikro.

Di sini lah kelompok kami memberikan solusi dalam bentuk rangkaian mikrokontroller yang berfungsi untuk mendeteksi suhu sekitarnya dan secara automatis akan mengubah kecepatan kipas untuk menyesuaikan dengan kebutuhan. Solusi kami tentunya akan memberikan peningkatan dalam efisiensi penggunaan daya dalam penggunaan kipas  dalam kasus-kasus di atas. Kemudian karena ditulis dengan bahasa assembly pastinya kode ini sangatlah flexible dan lightweight sehingga banyak mikrokontroller dapat mengimplementasinya.

## Hardware Design and Implementation Details
Pada proyek kali ini kami menggunakan beberapa komponen elektronik sebagai berikut:
- Arduino Uno
- Sensor DHT11
- I2C
- LCD
- Motor DC
- Kabel Jumper
- Breadboard
- L298n (Motor Driver)
- Kipas

Hardware yang digunakan terdiri dari satu buah Arduino Uno yang mencakup semua pustaka dan logika yang diperlukan untuk mengontrol kipas, membaca data dari sensor DHT11, dan menampilkan informasi yang diperoleh dari sensor tersebut pada layar LCD. Data dari sensor DHT11 akan menentukan apakah suhu cukup panas atau tidak. Kami juga menggunakan kipas ini yang terhubung ke Arduino Uno untuk menunjukkan keadaan sensor suhu saat ini dan berfungsi sebagai tanda fisik utama bahwa pengontrol kipas telah beralih mode.

Rentang suhu terbagi menjadi tiga kategori: dingin (low), normal (med), dan panas (high). Setiap kondisi diwakili oleh kecepatan kipas yang berbeda. Jika suhu yang terbaca termasuk dalam rentang dingin, kipas yang menyala memberikan kecepatan yang cukup lambat. Jika suhu yang terbaca termasuk dalam rentang normal, kipas yang menyala memberikan kecepatan normal. Jika suhu yang terbaca berada dalam rentang panas, kipas yang menyala mempunyai kecepatan tinggi. Kipas ini mengikuti output 1 dan 2 dari motor L298n di rangkaian atau L293D di proteus.

Data yang diterima oleh Arduino UNO ditampilkan pada LCD. Port yang bertanggung jawab untuk mengirimkan data yang ingin ditampilkan adalah PORTD dengan PD7 yang berfungsi sebagai pengirim data ke DHT11, PD6 pengirim data ke motor L298n, dan PD1 & PD0 utuk pengirim RXD & TXD ke serial monitor. 


## Software Implementation Details
Software dikembangkan menggunakan Arduino IDE dalam bahasa assembly AVR yang digunakan untuk ATMega328p.
Kami membuat kode untuk membaca data dari sensor DHT11 dan motor berdasarkan kondisi suhu.
Kode ini kemudian diunggah ke Arduino Uno untuk mengatur perilaku hardware sesuai dengan input yang diterima dari sensor suhu.

Kode Assembly di atas ditulis untuk mikrokontroler ATmega328P dan berfungsi sebagai sistem monitoring suhu dan kelembaban menggunakan sensor DHT11, sekaligus mengontrol kecepatan kipas berdasarkan suhu yang dibaca. Pertama, program menginisialisasi stack pointer dan mengatur PORTD sebagai output kecuali PD7, yang digunakan untuk komunikasi dengan DHT11. Timer0 dikonfigurasi untuk menghasilkan sinyal PWM pada pin output untuk mengendalikan kecepatan kipas.

Selanjutnya, komunikasi serial UART diatur dengan baudrate 9600, yang memungkinkan pengiriman data suhu dan kelembaban ke serial monitor. Program menunggu selama 2 detik agar sensor stabil, lalu masuk ke loop utama (main_loop) yang secara berkala membaca data dari sensor DHT11. Fungsi dht11_read menangani protokol komunikasi satu-wire dengan DHT11 untuk mengambil data suhu dan kelembaban.

Setelah data diambil, fungsi send_temp_message mengirimkan nilai suhu dan kelembaban dalam bentuk ASCII melalui UART. Berdasarkan nilai suhu, kecepatan kipas dikontrol melalui register OCR0A untuk menghasilkan PWM duty cycle berbeda: lambat (<25°C), sedang (25–29°C), atau cepat (≥30°C). Delay tambahan ditambahkan antar siklus untuk memberikan waktu proses berjalan dengan stabil. Kode juga menyertakan berbagai subrutin delay untuk mendukung timing presisi yang dibutuhkan oleh protokol DHT11 dan UART. Secara keseluruhan, kode ini adalah implementasi lengkap sistem berbasis mikrokontroler yang membaca data lingkungan dan merespons secara otomatis.

## Test Results and Performance Evaluation
Hasil pengujian menunjukkan bahwa sistem dapat mendeteksi suhu dengan baik menggunakan sensor DHT11. Suhu yang terdeteksi ditampilkan pada kecepatan kipas secara real-time. Kipas berfungsi sebagai indikator suhu, dengan kecepatan yang berbeda menunjukkan tingkat suhu yang berbeda.

Sistem bekerja sesuai dengan yang diharapkan, masalah yang diperoleh hanya berada pada rangkaian asli. Hal ini dikarenakan kipas yang seharusnya sebagai penanda sensor suhu tidak dapat berputar secara benar sehingga hanya dinamo motornya saja yang berputar. Ini kemungkinan disebabkan oleh tegangan yang tidak cukup tinggi yang diberikan dari Arduino. Asumsi ini terbukti benar ketika kami mencoba menyambungkan motor langsung ke ground dan sumber tegangan 5V dari Arduino, di mana motor dapat menyala dan berjalan secara normal. Hal ini menunjukkan bahwa sumber tegangan dari port D tidak cukup untuk menggerakkan motor, yang mungkin disebabkan oleh keterbatasan arus yang dapat disediakan oleh pin I/O Arduino.


## Conclusion and Future Work
Secara keseluruhan, sistem ini bekerja sesuai dengan yang diharapkan. Sebagian besar acceptance criteria terpenuhi. Proyek akhir ini bertujuan untuk mengembangkan solusi seperti layaknya kipas di laptop, dengan fokus pada efisiensi energi dan keandalan operasional. Sistem yang kami rancang menggunakan satu buah Arduino Uno yang berfungsi sebagai master. Ia bertugas untuk membaca data suhu dari sensor DHT11, mengontrol kipas sebagai indikator suhu, dan mengoperasikan kipasnya saat diperlukan. 

Namun, terdapat satu acceptance criteria yang belum terpenuhi: kipas kurang baik saat digunakan. Analisis kami menunjukkan bahwa masalah ini disebabkan oleh tegangan yang tidak cukup tinggi yang diberikan pada port D dari Arduino. Pengujian lebih lanjut menunjukkan bahwa motor dapat berjalan dengan normal saat dihubungkan langsung ke ground dan sumber tegangan 5V dari Arduino. Untuk menyelesaikan masalah ini, kami mempertimbangkan beberapa solusi, seperti USB tambahan atau transistor untuk meningkatkan tegangan dan arus yang diterima oleh motor. Dengan menggunakan USB tambahan atau transistor, kita dapat memastikan bahwa motor mendapatkan daya yang cukup tanpa membebani pin I/O dari Arduino. Selain itu, kami juga mempertimbangkan untuk menambahkan kapasitor untuk menstabilkan tegangan dan mengurangi fluktuasi yang mungkin terjadi saat motor dinyalakan.