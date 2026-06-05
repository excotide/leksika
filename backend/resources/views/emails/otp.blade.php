<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kode Verifikasi — Leksika</title>
    <style>
        /* ── RESET ── */
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

        /* Dekoratif lingkaran di header — tidak pakai konten nyata */
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

        /* Greeting dengan ikon wave sejajar teks */
        .greeting {
            font-size: 20px;
            font-weight: 700;
            color: #1E3F39;
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
            line-height: 1.3;
        }

        /* Gambar ikon greeting — ukuran sesuai baris teks */
        .greeting-icon {
            width: 24px;
            height: 24px;
            flex-shrink: 0;
            display: inline-block;
            vertical-align: middle;
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

        /* Garis hijau di atas OTP box */
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

        /* Wrapper ikon di info card */
        .info-card-icon {
            margin-bottom: 8px;
            line-height: 0;       /* hilangkan spasi bawah img bawaan browser */
        }

        /* Gambar ikon PNG di dalam card — ukuran tetap 28x28 */
        .info-card-icon img {
            width: 28px;
            height: 28px;
            display: inline-block;
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

        /* ══════════════════════════════════════════
           RESPONSIVE — TABLET / HP BESAR (≤ 600px)
           Target: Samsung Galaxy, iPhone 12/14, dll
           ══════════════════════════════════════════ */
        @media only screen and (max-width: 600px) {

            /* Kurangi padding luar supaya container tidak terlalu mepet */
            body {
                padding: 20px 12px;
            }

            /* Radius lebih kecil di mobile biar tidak aneh */
            .container {
                border-radius: 16px;
            }

            /* Header lebih compact */
            .header {
                padding: 36px 24px;
            }

            .header-logo {
                font-size: 26px;
            }

            .header-sub {
                font-size: 11px;
                letter-spacing: 2px;
            }

            /* Body padding dikurangi */
            .body {
                padding: 32px 24px;
            }

            .greeting {
                font-size: 18px;
            }

            /* OTP box full-width di mobile agar kode tidak terpotong */
            .otp-box {
                padding: 22px 20px;
                display: block;      /* dari inline-block → block, full lebar */
                width: 100%;
            }

            /* Kecilkan font + letter-spacing kode OTP agar muat di layar kecil */
            .otp-code {
                font-size: 34px;
                letter-spacing: 8px;
                text-indent: 8px;
            }

            /* Info card berubah jadi kolom vertikal —
               3 card sejajar di layar 360px terlalu sempit */
            .info-cards {
                flex-direction: column;
                gap: 10px;
            }

            /* Di mode vertikal, ikon dan teks disusun horizontal (baris) */
            .info-card {
                display: flex;
                align-items: center;
                gap: 14px;
                text-align: left;
                padding: 14px 16px;
            }

            /* Ikon tidak boleh mengecil walau flex squeeze */
            .info-card-icon {
                margin-bottom: 0;
                flex-shrink: 0;
            }

            .footer {
                padding: 24px;
            }
        }

        /* ══════════════════════════════
           HP SANGAT KECIL (≤ 360px)
           Target: iPhone SE, Android lama
           ══════════════════════════════ */
        @media only screen and (max-width: 360px) {

            /* Kecilkan lagi OTP supaya tidak overflow */
            .otp-code {
                font-size: 28px;
                letter-spacing: 6px;
                text-indent: 6px;
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

            {{-- Greeting: teks + ikon wave PNG (base64, aman di semua email client) --}}
            <p class="greeting">
                Halo, {{ $userName }}!
                <img
                    class="greeting-icon"
                    src="data:image/png;base64,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"
                    alt="Halo"
                    width="24"
                    height="24"
                >
            </p>

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

            {{-- Info cards: setiap ikon pakai <img> PNG base64 --}}
            <div class="info-cards">

                {{-- Card 1: durasi berlaku --}}
                <div class="info-card">
                    <div class="info-card-icon">
                        <img
                            src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAYAAADimHc4AAAABmJLR0QA/wD/AP+gvaeTAAAKn0lEQVR4nO2da3CU1RmAn/fsLkGUiK2Ytg4VAYXR2g4CwdbSopDNReuMnRGtjtqxTMhuknYcqfzoH35oZ7wwbYVkA9aO4mgtzPhDkbAhGHtRpiHU6Q/UCMF6aWtQK2O8ZJPsd/rjC6KwZ3e/234r7vMz79nznu+833du73veQIUKFSpUqFChQoUKFb5sSNgN+BzNjXOJZGcEqiMbOcqW7qFAdTigPAzQ2nQeVnYbUFsijf2oyCo6dr5eIn1GVNgNAChx5wPUTuoMnfC/gLb4+WTlcCi6I3oOm3peC0X3JOXxBXyJCd8A9hvYH4Lm/rDffigHAwCoyCpKa4T+SZ2hE/4c8Fkqy9AvAO2NVUyoaZA5i8iU0wHIjn0EVe8TtT5mY3cm5BY6orwN0NIwG8VytF6McCGa+cAszO3WwJsIg2heRWQAUX3lsN43UW4GEFrjy7DUTaDrgPN9qvYwYu1Gy2Ok0n/DNlRZUB4GWL2ihlg0CdwCzA5Y22uIbMWyOunqORKwroKEa4Dmld8kqu5Ay2pgWom1Z0AeQay76Ox5s8S6PyUcAzT/aBqRsV8Ba4EpobThOBk093Na9d38ZvsnpVZeegO0xK9GZCPBDzVOeQ1oJ5V+ppRKS2eA9sYqJqwNQKuLX38A9KP1qyAvo/TbaDkK6kNbbJ2B6Blovo5mAch8hFpgumNNwiYiam2plrOlMUCyfh6abcBCB786gOg/IvQyc2w/65+bcKRz/fIow6ctRrIr0PIT4GIHv94P2VWkegM/JAzeAMmGJWj9DDCziNL2xKj0ZjrS//C1HYn4IlDNoG8Fqor4xREs6yo27x7wtR0nEKwB1sTrUPIkcEaBkmNoUhC7j64d/w60TS1Xn4sauxMtCSBWoPQI8GNS6d6gmhOcAZJ1cbR6msKrnD4k20pn78uBtSUXaxovQlkdwPICJTPA1UEZIRgD2MPOs+R/80eB20mluwJpQ3EIyYYEWm8ApuYpNwL6ClI9+/1vgN/YE+4L5B/zD2JxHZvT//RdvxtaGhci1nZgbp5SR4joy/z2IfhrgPbGKsatFxAuzVNqP1o3lcMxwOdoXfFVrMgOkMuMZUQGiMj3/Vyi+uuQmbA2FOj8PiSzvOw6H6Bjz3tkpsaBPmMZrReTzd7rp1r/vgB7h/u0WZMMMDrlSv7w1IhvOoPgtmumU5XpAxYZSmjQV5Hq6fZDnT8GsM92DmA+XjhIVF3Oxu53fNEXNC3xcxC1F/Sc3AXkMFOnf8uPsyN/hiD7YG22QTqKVtcH0vnNjXNpbsw3cbrDHiKvBW3oYD2HzMg6P1R5/wKS8VloOYR5vZ/wfal5ciRdMJFuifpWYJNBOoqOzfO6cfT+BWj1S0ydr/kLqfRmzzpO5ORIumAi3VLpTsyT8lSYuMOrCm8GaImfA/pnBukYKtuC3+6/tvj55A5jrJ2U+YlG0Q6M55SKXmP3gXu8GUCpJGZPVmcgxwtZvuJK5paO9AEE01c8DZEWL9V7MYCgudkgy6Bj93uou7yIqHuAMYP0FjzMpe4N0BpflmeZ9kjgp5qlZGP3W8BWg3QuLXXfc1u1ewNY6iZzrdr/iTdsRLbkEd7otloPQ5CuMwhe8t2ZUg507tqH8EpOmYipLwrizgAtDbMxBU2JftxtY8oeSz9hkFxAMj7LTZXuDCD6CrOMwLxHoaPYbZRprnRXpTtMB1UjzBzz3WlRNpwz1o8doXEyWpwEHHyKWwPMz90I+h1HL3yRsJ8t9wsmLHBTpTsDaIMy0yR1ajFo+Hvul7IAzg1w3XVTEM7NLdSmxp06mF+yb9K8qFCUxUk4N8BZo9WYdn6iTp3NlxFtekZF9mzHkXjODTAlY1aStcL2dq1l9YqaQDVYyvyMkWyh+KeTcDEHRPMoORarGRZyA7HoIMn6X7B+eTQQFSrPS6ZUtePqPDUmDCL8r0CJM9H8luGqAVrqLi9Jmzzg3AAT+YYZy/En6Jji7xV/B1F/JdHwsK/DkqXMQ7Bl5d4j5MG5AayYeZiJ5Gmcn9h3fF8soqSAvpVY9BUS8XZfhiVl5ZkDI46HYOcGeH/qB5i8XNoyLE99pmPn69RkakH/HDhaxC9mgDzAcFU/rU3neVMupme0iLzreBHi3ADbt48Bb+UWiqvNiCvWPzdBqmcj4xMLQB6hONfnQs++Y9MmFN5gy/7crss8uDyMM2xGzI0Ljt/vGSa166doaxlQTKypV9+x6SVztQl1uwrKrUyoDWz5V4iu3c9Tk1nsYFhyjv1si3PKtLtjGLdnQSaHy3TemWI6KQ2e4oYl91lS3o4txXTvTHQxi4KTcGcAFXnWKLOUa++Qb3x2WBL57BUjb1lSVMT8bIK5T/LgPjIuUX+Y3F6xl0ilnVyIC55j4Ytes6Qk6182zHOvkkqX6DT0GKJ7DJKL7AtxZcSW7iHvnd+wJM8iw+wpK4B7A2h5LI9sjet6yxVtmZ/Jgx/cS3CukGg4ZIgNGiebnceW3jc81F8+5A9AHiKVvgCXIZheDuM0wqMGWYyo8hy4WjZoWYc5+nsrHuJfvZ2GWlYn8HFOmZYkbU2XeKq/HGitvxhoNkg/RmtPoffeDNDVcwTkIYM0SjbbQdgpcbwhWGzCfKG7y+t9N+/+ALHuw77MnItlJBsSnnWERSLehvki9ygRa4NXFRGvFbBv6AOWzK0C+YGhxEqWztvJvqH/etZVStbULUbUE0DuoxWt76Jz9w6vavzxiE0989fY+XZyUYXFNq8XGUrK6hU1KLUNc1KPIUbH7vFDlT8GsG8LtucpMReRndx2TWkcNl5ob6wmGt2JOWGgRmjj4edG/VDnfQg6xsDQQWrnnY05C/o3iGYv49sXP8mLg6bLDuHS3ljNRPYpRL5rLKN5gFTadHHPMf465SNqLabQPZsrqMr0leVwtHpFDeNWH8gP85Tax3vVd/qp1l8DbOzOQHYVkG9ptghRe2mtz5fSoLQk4ouIRffmTbMgDKNl1aRH0Df8D0tJ9R4G3YSd7MiAnoPFC5P3cMPcJwiJeDvI8+RPEjuC0ETXrn/534CgSNSvBHZQMD2Y/jNKWulIHwisLbloa7pkcqO4rEDJDEquomPXniCaEezbZxvhSQpnLxy3r4LqewNPomofrK0D1mBa4x9nBCXXBtX5UIrPPxFfBLITKGbiHQO2IrKFzl37fG1HS30toptBbqaYZLHCMEJT0PfdSjP+JlbOQaJ/QuvcDu1cCK/Yd7J0L18b/7urtJVvx5aiInVofQPO4vf70XJ9EGP+iZQ2cWs2ey9a2l3o/RCkH/SgnZpe/oNlfT5xq1IzQJ+L3dHzgSUUztZ4Ihr4He9Wr/N7tWOi9CuQRLwR1CbzJe/QGEJoozO9q5RK/dsJF8vA0CGWLXyQiUwWWErhiTBoRhG5m08yN/LgnpJfsQr3rN7+vwG3Y58jlTp9/UeIfohI5L7JVAShUB7OkvbGmYxnk4jcTP7UkX5wCHiUqEqVQwq18jDAccROfCE3IhIH5vlU70GgB9GP09mzl8q/MCmSZHwWmisRLkWrBaAvBM7D3G4LeAMYRPQgyH4i6tkwh5hClLcBcrF+eZTh06cTGZ9x/L7axIdkY0ep+WjklL4oXqFChQoVKlSoUKFChVOC/wNjcErzeiMIcgAAAABJRU5ErkJggg=="
                            alt="Waktu"
                            width="28"
                            height="28"
                        >
                    </div>
                    <div class="info-card-text">
                        <strong>10 Menit</strong>
                        Masa berlaku kode
                    </div>
                </div>

                {{-- Card 2: kerahasiaan --}}
                <div class="info-card">
                    <div class="info-card-icon">
                        <img
                            src="data:image/png;base64,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"
                            alt="Rahasia"
                            width="28"
                            height="28"
                        >
                    </div>
                    <div class="info-card-text">
                        <strong>Rahasia</strong>
                        Jangan bagikan ke siapapun
                    </div>
                </div>

                {{-- Card 3: sekali pakai --}}
                <div class="info-card">
                    <div class="info-card-icon">
                        <img
                            src="data:image/png;base64,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"
                            alt="Sekali pakai"
                            width="28"
                            height="28"
                        >
                    </div>
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
                &copy; {{ date('Y') }} Leksika. All rights reserved.<br>
                Email ini dikirim otomatis &mdash; mohon tidak membalas.
            </p>
        </div>

    </div>
</body>
</html>