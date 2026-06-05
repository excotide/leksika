<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kode Verifikasi — Leksika</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            background-color: #EAE4D6;
            font-family: Georgia, 'Times New Roman', serif;
            color: #1A2E2B;
            padding: 48px 20px;
        }

        .container {
            max-width: 560px;
            margin: 0 auto;
            background: #FFFFFF;
            border-radius: 24px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(30, 63, 57, 0.12);
        }

        /* ── HEADER ── */
        .header {
            background: #1E3F39;
            padding: 48px 40px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .header::before {
            content: '';
            position: absolute;
            top: -60px; right: -60px;
            width: 200px; height: 200px;
            border-radius: 50%;
            background: rgba(118, 176, 166, 0.1);
        }

        .header::after {
            content: '';
            position: absolute;
            bottom: -40px; left: -40px;
            width: 140px; height: 140px;
            border-radius: 50%;
            background: rgba(0, 105, 71, 0.15);
        }

        .header-logo {
            font-size: 32px;
            font-weight: 900;
            letter-spacing: -1px;
            color: #FFFFFF;
            position: relative;
            z-index: 1;
        }

        .header-logo span { color: #76B0A6; }

        .header-sub {
            font-family: 'Segoe UI', Arial, sans-serif;
            font-size: 12px;
            font-weight: 400;
            letter-spacing: 3px;
            text-transform: uppercase;
            color: #76B0A6;
            margin-top: 8px;
            position: relative;
            z-index: 1;
        }

        .header-divider {
            width: 40px;
            height: 2px;
            background: #006947;
            margin: 16px auto 0;
            border-radius: 2px;
            position: relative;
            z-index: 1;
        }

        /* ── BODY ── */
        .body {
            padding: 44px 40px;
        }

        .greeting {
            font-size: 20px;
            font-weight: 700;
            color: #1E3F39;
            margin-bottom: 14px;
        }

        .message {
            font-family: 'Segoe UI', Arial, sans-serif;
            font-size: 14px;
            color: #3D5F5A;
            line-height: 1.8;
            margin-bottom: 36px;
        }

        /* ── OTP BOX ── */
        .otp-wrapper {
            text-align: center;
            margin-bottom: 36px;
        }

        .otp-label {
            font-family: 'Segoe UI', Arial, sans-serif;
            font-size: 11px;
            font-weight: 600;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: #6B8F8A;
            margin-bottom: 16px;
        }

        .otp-box {
            background: #F5F0E8;
            border: 2px solid #A8D5CE;
            border-radius: 16px;
            padding: 28px 40px;
            display: inline-block;
            position: relative;
        }

        /* Garis aksen hijau di atas box */
        .otp-box::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
            background: linear-gradient(90deg, #006947, #76B0A6);
            border-radius: 16px 16px 0 0;
        }

        .otp-code {
            font-size: 48px;
            font-weight: 900;
            letter-spacing: 14px;
            color: #1E3F39;
            font-family: 'Courier New', monospace;
            text-indent: 14px;
        }

        /* ── DIVIDER ── */
        .divider {
            border: none;
            border-top: 1px solid #EAE4D6;
            margin: 32px 0;
        }

        /* ── INFO CARDS — layout baru ──
           Disusun vertikal satu-per-satu (bukan 3 kolom).
           Tiap card adalah baris horizontal: aksen warna kiri
           + label judul + deskripsi. Tidak ada ikon sama sekali.
        ── */
        .info-cards {
            display: flex;
            flex-direction: column; /* vertikal selalu, desktop maupun mobile */
            gap: 12px;
            margin-bottom: 32px;
        }

        .info-card {
            display: flex;
            align-items: stretch;   /* aksen bar setinggi card */
            background: #F5F0E8;
            border-radius: 12px;
            overflow: hidden;       /* supaya aksen bar ikut radius */
        }

        /* Aksen warna di sisi kiri setiap card */
        .info-card-accent {
            width: 4px;
            flex-shrink: 0;
            background: #006947;    /* default hijau */
        }

        /* Variasi warna aksen per card */
        .info-card:nth-child(2) .info-card-accent { background: #76B0A6; }
        .info-card:nth-child(3) .info-card-accent { background: #1E3F39; }

        /* Konten teks card */
        .info-card-content {
            padding: 16px 20px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .info-card-title {
            font-family: 'Segoe UI', Arial, sans-serif;
            font-size: 13px;
            font-weight: 700;
            color: #1E3F39;
            margin-bottom: 3px;
        }

        .info-card-desc {
            font-family: 'Segoe UI', Arial, sans-serif;
            font-size: 12px;
            color: #5A7A75;
            line-height: 1.5;
        }

        /* ── EXPIRE NOTE ── */
        .expire-note {
            font-family: 'Segoe UI', Arial, sans-serif;
            background: rgba(0, 105, 71, 0.06);
            border-left: 3px solid #006947;
            border-radius: 0 8px 8px 0;
            padding: 14px 16px;
            font-size: 12px;
            color: #3D5F5A;
            line-height: 1.7;
        }

        .expire-note strong { color: #006947; }

        /* ── FOOTER ── */
        .footer {
            background: #1E3F39;
            padding: 28px 40px;
            text-align: center;
        }

        .footer-logo {
            font-size: 16px;
            font-weight: 700;
            color: #FFFFFF;
            letter-spacing: -0.5px;
            margin-bottom: 10px;
        }

        .footer-logo span { color: #76B0A6; }

        .footer p {
            font-family: 'Segoe UI', Arial, sans-serif;
            font-size: 11px;
            color: #76B0A6;
            line-height: 1.7;
        }

        .footer-divider {
            width: 30px;
            height: 1px;
            background: rgba(118, 176, 166, 0.3);
            margin: 12px auto;
        }

        /* ══════════════════════════════════════════
           RESPONSIVE — MOBILE (≤ 600px)
        ══════════════════════════════════════════ */
        @media only screen and (max-width: 600px) {

            body { padding: 20px 12px; }

            .container { border-radius: 16px; }

            .header { padding: 36px 24px; }

            .header-logo { font-size: 26px; }

            .body { padding: 32px 24px; }

            .greeting { font-size: 18px; }

            /* OTP full-width di mobile */
            .otp-box {
                display: block;
                padding: 22px 20px;
            }

            /* Kecilkan kode OTP supaya tidak overflow */
            .otp-code {
                font-size: 36px;
                letter-spacing: 10px;
                text-indent: 10px;
            }

            /* Info cards sudah vertikal, tinggal sesuaikan padding */
            .info-card-content { padding: 14px 18px; }

            .footer { padding: 24px; }
        }

        /* HP sangat kecil ≤ 360px */
        @media only screen and (max-width: 360px) {
            .otp-code {
                font-size: 28px;
                letter-spacing: 7px;
                text-indent: 7px;
            }
        }
    </style>
</head>
<body>
    <div class="container">

        {{-- ── HEADER ── --}}
        <div class="header">
            <div class="header-logo">Leksi<span>ka</span></div>
            <div class="header-sub">Verifikasi Email</div>
            <div class="header-divider"></div>
        </div>

        {{-- ── BODY ── --}}
        <div class="body">

            <p class="greeting">Halo, {{ $userName }}!</p>

            <p class="message">
                Terima kasih sudah mendaftar di Leksika. Gunakan kode OTP berikut
                untuk memverifikasi alamat email kamu dan mulai perjalanan belajarmu.
            </p>

            {{-- OTP Box --}}
            <div class="otp-wrapper">
                <div class="otp-label">Kode Verifikasi</div>
                <div class="otp-box">
                    <div class="otp-code">{{ $otp }}</div>
                </div>
            </div>

            {{-- Info cards — 3 baris vertikal, tanpa ikon --}}
            <div class="info-cards">

                <div class="info-card">
                    <div class="info-card-accent"></div>
                    <div class="info-card-content">
                        <div class="info-card-title">Berlaku 10 Menit</div>
                        <div class="info-card-desc">Kode akan kedaluwarsa 10 menit setelah email ini dikirim.</div>
                    </div>
                </div>

                <div class="info-card">
                    <div class="info-card-accent"></div>
                    <div class="info-card-content">
                        <div class="info-card-title">Jaga Kerahasiaannya</div>
                        <div class="info-card-desc">Jangan bagikan kode ini kepada siapapun, termasuk tim Leksika.</div>
                    </div>
                </div>

                <div class="info-card">
                    <div class="info-card-accent"></div>
                    <div class="info-card-content">
                        <div class="info-card-title">Hanya Sekali Pakai</div>
                        <div class="info-card-desc">Kode otomatis tidak berlaku setelah digunakan satu kali.</div>
                    </div>
                </div>

            </div>

            <hr class="divider">

            <div class="expire-note">
                Jika kamu tidak merasa mendaftar di Leksika, abaikan email ini.
                Akun tidak akan dibuat tanpa verifikasi. Butuh bantuan?
                Hubungi <strong>support@leksika.id</strong>
            </div>
        </div>

        {{-- ── FOOTER ── --}}
        <div class="footer">
            <div class="footer-logo">Leksi<span>ka</span></div>
            <div class="footer-divider"></div>
            <p>
                &copy; {{ date('Y') }} Leksika. All rights reserved.<br>
                Email ini dikirim otomatis &mdash; mohon tidak membalas.
            </p>
        </div>

    </div>
</body>
</html>