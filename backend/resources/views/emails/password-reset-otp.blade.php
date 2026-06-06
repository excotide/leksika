<!DOCTYPE html>
<html lang="id" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="color-scheme" content="light">
    <meta name="supported-color-schemes" content="light">
    <title>Reset Password — Leksika</title>
    <style>
        /* Paksa light mode — cegah email client dark mode override warna */
        :root { color-scheme: light only; }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        /* Wrapper luar — background halaman */
        body,
        .body-wrapper {
            background-color: #EAE4D6 !important;
            font-family: Georgia, 'Times New Roman', serif;
            color: #1A2E2B !important;
            margin: 0 !important;
            padding: 0 !important;
            width: 100% !important;
            -webkit-text-size-adjust: 100%;
            -ms-text-size-adjust: 100%;
        }

        /* ── OUTER PADDING TABLE ── */
        .outer-table {
            width: 100%;
            background-color: #EAE4D6 !important;
        }

        /* ── CONTAINER ── */
        .container {
            max-width: 560px;
            width: 100%;
            margin: 0 auto;
            background-color: #FFFFFF !important;
            border-radius: 20px;
            overflow: hidden;
        }

        /* ── HEADER ── */
        .header {
            background-color: #1E3F39 !important;
            padding: 44px 40px;
            text-align: center;
        }

        .header-logo {
            font-size: 30px;
            font-weight: 900;
            letter-spacing: -1px;
            color: #FFFFFF !important;
            font-family: Georgia, serif;
        }

        .header-logo-accent { color: #76B0A6 !important; }

        .header-sub {
            font-family: Arial, sans-serif;
            font-size: 11px;
            font-weight: 400;
            letter-spacing: 3px;
            text-transform: uppercase;
            color: #76B0A6 !important;
            margin-top: 8px;
            display: block;
        }

        /* Garis aksen di bawah sub-header */
        .header-line {
            width: 40px;
            height: 2px;
            background-color: #006947 !important;
            margin: 14px auto 0;
            display: block;
            border-radius: 2px;
        }

        /* ── BODY ── */
        .email-body {
            background-color: #FFFFFF !important;
            padding: 40px 40px 36px;
        }

        /* Greeting */
        .greeting {
            font-size: 20px;
            font-weight: 700;
            color: #1E3F39 !important;
            font-family: Georgia, serif;
            margin-bottom: 12px;
            display: block;
        }

        /* Teks penjelasan */
        .message {
            font-family: Arial, sans-serif;
            font-size: 14px;
            color: #3D5F5A !important;
            line-height: 1.8;
            margin-bottom: 32px;
            display: block;
        }

        /* ── OTP WRAPPER ── */
        .otp-label {
            font-family: Arial, sans-serif;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 2.5px;
            text-transform: uppercase;
            color: #6B8F8A !important;
            text-align: center;
            display: block;
            margin-bottom: 14px;
        }

        /* Kotak OTP — full width supaya rapi di mobile */
        .otp-box {
            background-color: #F5F0E8 !important;
            border: 2px solid #A8D5CE !important;
            border-top: 4px solid #006947 !important;
            border-radius: 14px;
            padding: 26px 20px;
            text-align: center;
            margin-bottom: 32px;
            display: block;
        }

        /* Angka OTP besar */
        .otp-code {
            font-family: 'Courier New', Courier, monospace;
            font-size: 46px;
            font-weight: 900;
            letter-spacing: 12px;
            color: #1E3F39 !important;
            text-indent: 12px;
            display: block;
        }

        /* ── GARIS PEMBATAS ── */
        .divider {
            border: none;
            border-top: 1px solid #EAE4D6 !important;
            margin: 8px 0 28px;
        }

        /* ── INFO CARDS — layout baris vertikal ──
           Setiap card: aksen bar kiri + teks judul + deskripsi.
           Disusun ke bawah, tidak pernah sejajar ke kanan.
        ── */
        .info-cards {
            margin-bottom: 28px;
        }

        /* Wrapper tiap card — pakai table-cell supaya aksen bar
           bisa setinggi card tanpa CSS height tricks */
        .info-card-wrap {
            display: table;
            width: 100%;
            margin-bottom: 10px;
            background-color: #F5F0E8 !important;
            border-radius: 10px;
            overflow: hidden;
        }

        /* Kolom aksen warna di kiri — lebar tetap 5px */
        .info-card-bar {
            display: table-cell;
            width: 5px;
            min-width: 5px;
            background-color: #006947 !important;
            border-radius: 10px 0 0 10px;
        }

        /* Variasi warna per card */
        .info-card-bar-teal    { background-color: #76B0A6 !important; }
        .info-card-bar-dark    { background-color: #1E3F39 !important; }

        /* Kolom konten teks */
        .info-card-content {
            display: table-cell;
            vertical-align: middle;
            padding: 14px 18px;
        }

        .info-card-title {
            font-family: Arial, sans-serif;
            font-size: 13px;
            font-weight: 700;
            color: #1E3F39 !important;
            display: block;
            margin-bottom: 2px;
        }

        .info-card-desc {
            font-family: Arial, sans-serif;
            font-size: 12px;
            color: #5A7A75 !important;
            line-height: 1.5;
            display: block;
        }

        /* ── CATATAN EXPIRE ── */
        .expire-note {
            background-color: rgba(0, 105, 71, 0.06) !important;
            border-left: 3px solid #006947 !important;
            border-radius: 0 8px 8px 0;
            padding: 14px 16px;
            font-family: Arial, sans-serif;
            font-size: 12px;
            color: #3D5F5A !important;
            line-height: 1.7;
            display: block;
        }

        .expire-email {
            color: #006947 !important;
            font-weight: 700;
        }

        /* ── FOOTER ── */
        .footer {
            background-color: #1E3F39 !important;
            padding: 26px 40px;
            text-align: center;
        }

        .footer-logo {
            font-size: 15px;
            font-weight: 700;
            color: #FFFFFF !important;
            font-family: Georgia, serif;
            display: block;
            margin-bottom: 10px;
        }

        .footer-logo-accent { color: #76B0A6 !important; }

        .footer-line {
            width: 30px;
            height: 1px;
            background-color: rgba(118, 176, 166, 0.35) !important;
            margin: 0 auto 12px;
            display: block;
        }

        .footer-text {
            font-family: Arial, sans-serif;
            font-size: 11px;
            color: #76B0A6 !important;
            line-height: 1.7;
        }

        /* ══════════════════════════════════
           RESPONSIVE MOBILE (≤ 600px)
        ══════════════════════════════════ */
        @media only screen and (max-width: 600px) {

            /* Padding luar lebih tipis di mobile */
            .email-body { padding: 32px 24px 28px !important; }
            .header     { padding: 36px 24px !important; }
            .footer     { padding: 22px 24px !important; }

            .header-logo  { font-size: 26px !important; }
            .greeting     { font-size: 18px !important; }

            /* OTP kecil supaya tidak keluar layar */
            .otp-code {
                font-size: 36px !important;
                letter-spacing: 8px !important;
                text-indent: 8px !important;
            }
        }

        /* HP sangat kecil ≤ 380px */
        @media only screen and (max-width: 380px) {
            .otp-code {
                font-size: 30px !important;
                letter-spacing: 6px !important;
                text-indent: 6px !important;
            }
        }
    </style>
</head>

<!--
    Catatan: gunakan meta color-scheme "light only" supaya
    email client tidak membalik warna ke dark mode secara paksa.
-->
<body style="margin:0;padding:0;background-color:#EAE4D6;">

    {{-- Outer table: full-width background halaman --}}
    <table class="outer-table" role="presentation" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td align="center" style="padding:40px 16px;background-color:#EAE4D6;">

                {{-- Container utama email --}}
                <table class="container" role="presentation" cellpadding="0" cellspacing="0" width="560">
                    <tr>
                        <td>

                            {{-- ── HEADER ── --}}
                            <div class="header">
                                <span class="header-logo">
                                    Leksi<span class="header-logo-accent">ka</span>
                                </span>
                                <span class="header-sub">Reset Password</span>
                                <span class="header-line"></span>
                            </div>

                            {{-- ── BODY ── --}}
                            <div class="email-body">

                                {{-- Sapaan --}}
                                <span class="greeting">Halo, {{ $userName }}!</span>

                                {{-- Penjelasan singkat --}}
                                <span class="message">
                                    Kami menerima permintaan reset password untuk akun Leksika kamu.
                                    Gunakan kode OTP berikut untuk melanjutkan proses reset password.
                                </span>

                                {{-- Label & kotak OTP --}}
                                <span class="otp-label">Kode Reset Password</span>
                                <div class="otp-box">
                                    <span class="otp-code">{{ $otp }}</span>
                                </div>

                                {{-- ── INFO CARDS — 3 baris vertikal ──
                                     Struktur: table → 2 kolom (bar warna | konten teks)
                                     Pakai display:table agar bar setinggi card di semua client
                                ── --}}
                                <div class="info-cards">

                                    {{-- Card 1: durasi berlaku --}}
                                    <div class="info-card-wrap">
                                        <div class="info-card-bar"></div>
                                        <div class="info-card-content">
                                            <span class="info-card-title">Berlaku 10 Menit</span>
                                            <span class="info-card-desc">Kode akan kedaluwarsa 10 menit setelah email ini dikirim.</span>
                                        </div>
                                    </div>

                                    {{-- Card 2: kerahasiaan --}}
                                    <div class="info-card-wrap">
                                        <div class="info-card-bar info-card-bar-teal"></div>
                                        <div class="info-card-content">
                                            <span class="info-card-title">Jaga Kerahasiaannya</span>
                                            <span class="info-card-desc">Jangan bagikan kode ini kepada siapapun, termasuk tim Leksika.</span>
                                        </div>
                                    </div>

                                    {{-- Card 3: sekali pakai --}}
                                    <div class="info-card-wrap">
                                        <div class="info-card-bar info-card-bar-dark"></div>
                                        <div class="info-card-content">
                                            <span class="info-card-title">Hanya Sekali Pakai</span>
                                            <span class="info-card-desc">Kode otomatis tidak berlaku setelah digunakan satu kali.</span>
                                        </div>
                                    </div>

                                </div>

                                <hr class="divider">

                                {{-- Catatan jika bukan pengirim --}}
                                <div class="expire-note">
                                    Jika kamu tidak merasa meminta reset password, abaikan email ini.
                                    Password kamu tidak akan berubah. Butuh bantuan?
                                    Hubungi <span class="expire-email">support@leksika.id</span>
                                </div>

                            </div>
                            {{-- end email-body --}}

                            {{-- ── FOOTER ── --}}
                            <div class="footer">
                                <span class="footer-logo">
                                    Leksi<span class="footer-logo-accent">ka</span>
                                </span>
                                <span class="footer-line"></span>
                                <p class="footer-text">
                                    &copy; {{ date('Y') }} Leksika. All rights reserved.<br>
                                    Email ini dikirim otomatis &mdash; mohon tidak membalas.
                                </p>
                            </div>

                        </td>
                    </tr>
                </table>
                {{-- end container --}}

            </td>
        </tr>
    </table>

</body>
</html>
