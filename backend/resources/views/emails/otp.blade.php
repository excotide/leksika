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
            margin: 28px 0;
        }

        /* ── INFO CARDS ── */
        .info-cards {
            display: flex;
            gap: 12px;
            margin-bottom: 28px;
        }

        .info-card {
            flex: 1;
            background: #F5F0E8;
            border-radius: 12px;
            padding: 16px;
            text-align: center;
        }

        .info-card-icon {
            font-size: 20px;
            margin-bottom: 6px;
        }

        .info-card-text {
            font-family: 'Segoe UI', Arial, sans-serif;
            font-size: 11px;
            color: #3D5F5A;
            line-height: 1.5;
            font-weight: 500;
        }

        .info-card-text strong {
            display: block;
            color: #1E3F39;
            font-size: 12px;
            margin-bottom: 2px;
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
            <p class="greeting">Halo, {{ $userName }}! 👋</p>
            <p class="message">
                Terima kasih sudah mendaftar di Leksika. Gunakan kode OTP berikut
                untuk memverifikasi alamat email kamu dan mulai perjalanan belajarmu.
            </p>

            <div class="otp-wrapper">
                <div class="otp-label">Kode Verifikasi</div>
                <div class="otp-box">
                    <div class="otp-code">{{ $otp }}</div>
                </div>
            </div>

            <div class="info-cards">
                <div class="info-card">
                    <div class="info-card-icon">⏱</div>
                    <div class="info-card-text">
                        <strong>10 Menit</strong>
                        Masa berlaku kode
                    </div>
                </div>
                <div class="info-card">
                    <div class="info-card-icon">🔒</div>
                    <div class="info-card-text">
                        <strong>Rahasia</strong>
                        Jangan bagikan ke siapapun
                    </div>
                </div>
                <div class="info-card">
                    <div class="info-card-icon">1️⃣</div>
                    <div class="info-card-text">
                        <strong>Sekali Pakai</strong>
                        Kode hanya berlaku 1x
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
                © {{ date('Y') }} Leksika. All rights reserved.<br>
                Email ini dikirim otomatis — mohon tidak membalas.
            </p>
        </div>

    </div>
</body>
</html>