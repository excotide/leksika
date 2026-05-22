<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leksika — Belajar Lebih Cerdas</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --teal-deep:    #1E3F39;
            --teal-mid:     #2D6A5F;
            --teal-soft:    #76B0A6;
            --teal-light:   #A8D5CE;
            --green-accent: #006947;
            --cream:        #F5F0E8;
            --cream-dark:   #EAE4D6;
            --white:        #FFFFFF;
            --text-dark:    #1A2E2B;
            --text-mid:     #3D5F5A;
            --text-soft:    #6B8F8A;
            --font-display: 'Playfair Display', Georgia, serif;
            --font-body:    'DM Sans', sans-serif;
        }

        html { scroll-behavior: smooth; }

        body {
            font-family: var(--font-body);
            background: var(--cream);
            color: var(--text-dark);
            overflow-x: hidden;
        }

        /* ── NOISE TEXTURE OVERLAY ── */
        body::before {
            content: '';
            position: fixed;
            inset: 0;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.03'/%3E%3C/svg%3E");
            pointer-events: none;
            z-index: 1000;
            opacity: 0.4;
        }

        /* ── NAVBAR ── */
        nav {
            position: fixed;
            top: 0; left: 0; right: 0;
            z-index: 100;
            padding: 20px 60px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            backdrop-filter: blur(12px);
            background: rgba(245, 240, 232, 0.85);
            border-bottom: 1px solid rgba(118, 176, 166, 0.2);
            transition: all 0.3s ease;
        }

        .nav-logo {
            font-family: var(--font-display);
            font-size: 1.6rem;
            font-weight: 700;
            color: var(--teal-deep);
            text-decoration: none;
            letter-spacing: -0.5px;
        }

        .nav-logo span {
            color: var(--green-accent);
        }

        .nav-links {
            display: flex;
            gap: 36px;
            list-style: none;
        }

        .nav-links a {
            font-size: 0.9rem;
            font-weight: 500;
            color: var(--text-mid);
            text-decoration: none;
            letter-spacing: 0.3px;
            transition: color 0.2s;
        }

        .nav-links a:hover { color: var(--green-accent); }

        .nav-cta {
            background: var(--green-accent);
            color: var(--white) !important;
            padding: 10px 24px;
            border-radius: 100px;
            font-weight: 600 !important;
            transition: all 0.3s ease !important;
        }

        .nav-cta:hover {
            background: var(--teal-deep) !important;
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0, 105, 71, 0.3);
        }

        /* ── HERO ── */
        .hero {
            min-height: 100vh;
            display: grid;
            grid-template-columns: 1fr 1fr;
            align-items: center;
            padding: 120px 60px 80px;
            position: relative;
            overflow: hidden;
            gap: 60px;
        }

        .hero-bg-circle {
            position: absolute;
            border-radius: 50%;
            filter: blur(80px);
            opacity: 0.15;
            animation: floatOrb 8s ease-in-out infinite;
        }

        .hero-bg-circle.c1 {
            width: 500px; height: 500px;
            background: var(--teal-soft);
            top: -100px; right: -100px;
            animation-delay: 0s;
        }

        .hero-bg-circle.c2 {
            width: 300px; height: 300px;
            background: var(--green-accent);
            bottom: 50px; left: 100px;
            animation-delay: 3s;
        }

        @keyframes floatOrb {
            0%, 100% { transform: translate(0, 0) scale(1); }
            50% { transform: translate(20px, -30px) scale(1.05); }
        }

        .hero-content {
            position: relative;
            z-index: 2;
            animation: fadeInUp 0.9s ease both;
        }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(0, 105, 71, 0.1);
            border: 1px solid rgba(0, 105, 71, 0.25);
            color: var(--green-accent);
            font-size: 0.78rem;
            font-weight: 600;
            padding: 6px 16px;
            border-radius: 100px;
            margin-bottom: 28px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        .hero-badge::before {
            content: '';
            width: 6px; height: 6px;
            background: var(--green-accent);
            border-radius: 50%;
            animation: pulse 2s ease infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.5; transform: scale(1.5); }
        }

        .hero-title {
            font-family: var(--font-display);
            font-size: clamp(2.8rem, 5vw, 4.2rem);
            font-weight: 900;
            line-height: 1.1;
            color: var(--teal-deep);
            margin-bottom: 24px;
            letter-spacing: -1.5px;
        }

        .hero-title .accent {
            color: var(--green-accent);
            font-style: italic;
        }

        .hero-title .underline-wave {
            position: relative;
            display: inline-block;
        }

        .hero-title .underline-wave::after {
            content: '';
            position: absolute;
            bottom: -4px; left: 0; right: 0;
            height: 4px;
            background: var(--teal-soft);
            border-radius: 2px;
        }

        .hero-desc {
            font-size: 1.1rem;
            color: var(--text-mid);
            line-height: 1.75;
            max-width: 480px;
            margin-bottom: 40px;
            font-weight: 300;
        }

        .hero-actions {
            display: flex;
            gap: 16px;
            align-items: center;
        }

        .btn-primary {
            background: var(--green-accent);
            color: var(--white);
            padding: 16px 36px;
            border-radius: 100px;
            font-size: 1rem;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s ease;
            box-shadow: 0 4px 20px rgba(0, 105, 71, 0.3);
        }

        .btn-primary:hover {
            background: var(--teal-deep);
            transform: translateY(-3px);
            box-shadow: 0 12px 32px rgba(0, 105, 71, 0.4);
        }

        .btn-secondary {
            color: var(--teal-deep);
            font-weight: 600;
            text-decoration: none;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: gap 0.3s ease;
        }

        .btn-secondary:hover { gap: 14px; }

        .btn-secondary::after {
            content: '→';
            font-size: 1.1rem;
        }

        /* ── HERO VISUAL ── */
        .hero-visual {
            position: relative;
            z-index: 2;
            animation: fadeInRight 0.9s ease 0.2s both;
        }

        .hero-card {
            background: var(--white);
            border-radius: 24px;
            padding: 32px;
            box-shadow: 0 20px 60px rgba(30, 63, 57, 0.12);
            position: relative;
            overflow: hidden;
        }

        .hero-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--green-accent), var(--teal-soft));
        }

        .card-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 24px;
        }

        .card-avatar {
            width: 44px; height: 44px;
            background: linear-gradient(135deg, var(--teal-soft), var(--green-accent));
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
        }

        .card-title {
            font-weight: 600;
            font-size: 0.95rem;
            color: var(--teal-deep);
        }

        .card-sub {
            font-size: 0.78rem;
            color: var(--text-soft);
        }

        .doc-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 16px;
            background: var(--cream);
            border-radius: 12px;
            margin-bottom: 10px;
            transition: all 0.2s;
        }

        .doc-item:hover {
            background: var(--cream-dark);
            transform: translateX(4px);
        }

        .doc-icon {
            width: 36px; height: 36px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1rem;
            flex-shrink: 0;
        }

        .doc-icon.pdf { background: rgba(239, 68, 68, 0.1); }
        .doc-icon.img { background: rgba(59, 130, 246, 0.1); }
        .doc-icon.doc { background: rgba(0, 105, 71, 0.1); }

        .doc-name {
            font-size: 0.85rem;
            font-weight: 500;
            color: var(--text-dark);
        }

        .doc-meta {
            font-size: 0.72rem;
            color: var(--text-soft);
        }

        .doc-badge {
            margin-left: auto;
            font-size: 0.7rem;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 100px;
            background: rgba(0, 105, 71, 0.1);
            color: var(--green-accent);
        }

        .floating-card {
            position: absolute;
            background: var(--white);
            border-radius: 16px;
            padding: 14px 18px;
            box-shadow: 0 8px 32px rgba(30, 63, 57, 0.15);
            animation: floatCard 4s ease-in-out infinite;
        }

        .floating-card.quiz {
            bottom: -20px; left: -30px;
            animation-delay: 1s;
        }

        .floating-card.score {
            top: -20px; right: -20px;
            animation-delay: 2s;
        }

        @keyframes floatCard {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        .float-label {
            font-size: 0.7rem;
            color: var(--text-soft);
            font-weight: 500;
            margin-bottom: 4px;
        }

        .float-value {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--teal-deep);
        }

        .float-value span {
            font-size: 0.75rem;
            color: var(--green-accent);
            font-weight: 500;
        }

        /* ── STATS ── */
        .stats {
            background: var(--teal-deep);
            padding: 60px;
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 40px;
            position: relative;
            overflow: hidden;
        }

        .stats::before {
            content: '';
            position: absolute;
            inset: 0;
            background: repeating-linear-gradient(
                45deg,
                transparent,
                transparent 40px,
                rgba(255,255,255,0.02) 40px,
                rgba(255,255,255,0.02) 41px
            );
        }

        .stat-item {
            text-align: center;
            position: relative;
            z-index: 1;
            animation: countUp 0.6s ease both;
        }

        .stat-number {
            font-family: var(--font-display);
            font-size: 3rem;
            font-weight: 900;
            color: var(--white);
            line-height: 1;
            margin-bottom: 8px;
        }

        .stat-number .accent { color: var(--teal-light); }

        .stat-label {
            font-size: 0.85rem;
            color: var(--teal-light);
            font-weight: 400;
        }

        /* ── FEATURES ── */
        .features {
            padding: 120px 60px;
            max-width: 1200px;
            margin: 0 auto;
        }

        .section-label {
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: var(--green-accent);
            margin-bottom: 16px;
        }

        .section-title {
            font-family: var(--font-display);
            font-size: clamp(2rem, 4vw, 3rem);
            font-weight: 800;
            color: var(--teal-deep);
            line-height: 1.15;
            letter-spacing: -1px;
            margin-bottom: 16px;
        }

        .section-desc {
            font-size: 1rem;
            color: var(--text-soft);
            max-width: 500px;
            line-height: 1.7;
            margin-bottom: 64px;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 24px;
        }

        .feature-card {
            background: var(--white);
            border-radius: 20px;
            padding: 36px 30px;
            border: 1px solid rgba(118, 176, 166, 0.2);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .feature-card::before {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, rgba(0,105,71,0.03), transparent);
            opacity: 0;
            transition: opacity 0.3s;
        }

        .feature-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 20px 48px rgba(30, 63, 57, 0.1);
            border-color: rgba(0, 105, 71, 0.3);
        }

        .feature-card:hover::before { opacity: 1; }

        .feature-icon {
            width: 52px; height: 52px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
            margin-bottom: 20px;
        }

        .feature-icon.green { background: rgba(0, 105, 71, 0.1); }
        .feature-icon.teal  { background: rgba(118, 176, 166, 0.2); }
        .feature-icon.deep  { background: rgba(30, 63, 57, 0.08); }

        .feature-title {
            font-family: var(--font-display);
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--teal-deep);
            margin-bottom: 12px;
        }

        .feature-desc {
            font-size: 0.9rem;
            color: var(--text-soft);
            line-height: 1.7;
        }

        /* ── HOW IT WORKS ── */
        .how {
            background: var(--teal-deep);
            padding: 120px 60px;
            position: relative;
            overflow: hidden;
        }

        .how::after {
            content: 'LEKSIKA';
            position: absolute;
            font-family: var(--font-display);
            font-size: 20vw;
            font-weight: 900;
            color: rgba(255,255,255,0.03);
            bottom: -40px;
            right: -20px;
            line-height: 1;
            pointer-events: none;
            letter-spacing: -5px;
        }

        .how-inner {
            max-width: 1200px;
            margin: 0 auto;
        }

        .how .section-title { color: var(--white); }
        .how .section-desc  { color: var(--teal-light); }

        .steps {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 32px;
            position: relative;
            z-index: 1;
        }

        .steps::before {
            content: '';
            position: absolute;
            top: 28px;
            left: 10%;
            right: 10%;
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(118,176,166,0.4), transparent);
        }

        .step {
            text-align: center;
            position: relative;
        }

        .step-num {
            width: 56px; height: 56px;
            border-radius: 50%;
            background: rgba(118, 176, 166, 0.15);
            border: 1px solid rgba(118, 176, 166, 0.3);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: var(--font-display);
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--teal-light);
            margin: 0 auto 20px;
        }

        .step-title {
            font-weight: 600;
            color: var(--white);
            margin-bottom: 10px;
            font-size: 1rem;
        }

        .step-desc {
            font-size: 0.85rem;
            color: var(--teal-light);
            line-height: 1.6;
        }

        /* ── TESTIMONIALS ── */
        .testimonials {
            padding: 120px 60px;
            background: var(--cream-dark);
        }

        .testimonials-inner {
            max-width: 1200px;
            margin: 0 auto;
        }

        .testi-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 24px;
        }

        .testi-card {
            background: var(--white);
            border-radius: 20px;
            padding: 32px;
            border: 1px solid rgba(118, 176, 166, 0.15);
            transition: all 0.3s ease;
        }

        .testi-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 16px 40px rgba(30, 63, 57, 0.08);
        }

        .testi-stars {
            color: #F59E0B;
            font-size: 0.85rem;
            margin-bottom: 16px;
            letter-spacing: 2px;
        }

        .testi-text {
            font-size: 0.95rem;
            color: var(--text-mid);
            line-height: 1.75;
            margin-bottom: 24px;
            font-style: italic;
        }

        .testi-author {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .testi-avatar {
            width: 40px; height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 0.85rem;
            color: var(--white);
        }

        .testi-name {
            font-weight: 600;
            font-size: 0.9rem;
            color: var(--teal-deep);
        }

        .testi-role {
            font-size: 0.78rem;
            color: var(--text-soft);
        }

        /* ── CTA ── */
        .cta {
            padding: 120px 60px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .cta-bg {
            position: absolute;
            inset: 0;
            background: radial-gradient(ellipse at center, rgba(0,105,71,0.06) 0%, transparent 70%);
        }

        .cta-inner {
            position: relative;
            z-index: 1;
            max-width: 640px;
            margin: 0 auto;
        }

        .cta .section-title {
            margin-bottom: 20px;
        }

        .cta-desc {
            font-size: 1.05rem;
            color: var(--text-soft);
            line-height: 1.7;
            margin-bottom: 40px;
        }

        .cta-actions {
            display: flex;
            gap: 16px;
            justify-content: center;
        }

        /* ── FOOTER ── */
        footer {
            background: var(--teal-deep);
            padding: 60px;
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr;
            gap: 48px;
        }

        .footer-brand .nav-logo {
            color: var(--white);
            display: block;
            margin-bottom: 16px;
            font-size: 1.8rem;
        }

        .footer-brand p {
            font-size: 0.88rem;
            color: var(--teal-light);
            line-height: 1.7;
            max-width: 260px;
        }

        .footer-col h4 {
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            color: var(--teal-light);
            margin-bottom: 20px;
        }

        .footer-col ul {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .footer-col a {
            font-size: 0.88rem;
            color: rgba(255,255,255,0.6);
            text-decoration: none;
            transition: color 0.2s;
        }

        .footer-col a:hover { color: var(--white); }

        .footer-bottom {
            background: rgba(0,0,0,0.2);
            padding: 20px 60px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .footer-bottom p {
            font-size: 0.82rem;
            color: var(--teal-light);
        }

        /* ── ANIMATIONS ── */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        @keyframes fadeInRight {
            from { opacity: 0; transform: translateX(30px); }
            to   { opacity: 1; transform: translateX(0); }
        }

        .reveal {
            opacity: 0;
            transform: translateY(24px);
            transition: opacity 0.7s ease, transform 0.7s ease;
        }

        .reveal.visible {
            opacity: 1;
            transform: translateY(0);
        }

        /* ── RESPONSIVE ── */
        @media (max-width: 1024px) {
            nav { padding: 20px 30px; }
            .hero { grid-template-columns: 1fr; padding: 100px 30px 60px; }
            .hero-visual { display: none; }
            .stats { grid-template-columns: repeat(2, 1fr); padding: 60px 30px; }
            .features { padding: 80px 30px; }
            .features-grid { grid-template-columns: 1fr 1fr; }
            .how { padding: 80px 30px; }
            .steps { grid-template-columns: repeat(2, 1fr); }
            .testimonials { padding: 80px 30px; }
            .testi-grid { grid-template-columns: 1fr; }
            .cta { padding: 80px 30px; }
            footer { grid-template-columns: 1fr 1fr; padding: 40px 30px; }
            .footer-bottom { padding: 20px 30px; flex-direction: column; gap: 8px; text-align: center; }
        }
    </style>
</head>
<body>

{{-- ── NAVBAR ── --}}
<nav>
    <a href="#" class="nav-logo">Leksi<span>ka</span></a>
    <ul class="nav-links">
        <li><a href="#fitur">Fitur</a></li>
        <li><a href="#cara-kerja">Cara Kerja</a></li>
        <li><a href="#testimoni">Testimoni</a></li>
        <li><a href="#" class="nav-cta">Mulai Gratis</a></li>
    </ul>
</nav>

{{-- ── HERO ── --}}
<section class="hero">
    <div class="hero-bg-circle c1"></div>
    <div class="hero-bg-circle c2"></div>

    <div class="hero-content">
        <div class="hero-badge">Platform Belajar Cerdas</div>
        <h1 class="hero-title">
            Ubah Dokumenmu<br>
            Jadi <span class="accent"><span class="underline-wave">Pengetahuan</span></span><br>
            yang Nyata
        </h1>
        <p class="hero-desc">
            Leksika membantu kamu memahami materi lebih dalam — unggah PDF atau gambar,
            dapatkan ringkasan cerdas dan kuis otomatis yang disesuaikan dengan kontenmu.
        </p>
        <div class="hero-actions">
            <a href="#" class="btn-primary">Coba Sekarang →</a>
            <a href="#fitur" class="btn-secondary">Lihat Fitur</a>
        </div>
    </div>

    <div class="hero-visual">
        <div style="position: relative; padding: 30px;">
            <div class="hero-card">
                <div class="card-header">
                    <div class="card-avatar">📚</div>
                    <div>
                        <div class="card-title">Dokumen Saya</div>
                        <div class="card-sub">3 dokumen aktif</div>
                    </div>
                </div>

                <div class="doc-item">
                    <div class="doc-icon pdf">📄</div>
                    <div>
                        <div class="doc-name">Struktur Data.pdf</div>
                        <div class="doc-meta">2.4 MB · Diupload kemarin</div>
                    </div>
                    <div class="doc-badge">Quiz Siap</div>
                </div>

                <div class="doc-item">
                    <div class="doc-icon img">🖼️</div>
                    <div>
                        <div class="doc-name">Catatan Kalkulus.jpg</div>
                        <div class="doc-meta">1.1 MB · 2 hari lalu</div>
                    </div>
                    <div class="doc-badge">Rangkuman</div>
                </div>

                <div class="doc-item">
                    <div class="doc-icon doc">📝</div>
                    <div>
                        <div class="doc-name">Algoritma Sorting.pdf</div>
                        <div class="doc-meta">3.8 MB · Minggu lalu</div>
                    </div>
                    <div class="doc-badge">Quiz Siap</div>
                </div>
            </div>

            <div class="floating-card quiz">
                <div class="float-label">🎯 Skor Quiz Terakhir</div>
                <div class="float-value">92 <span>/ 100</span></div>
            </div>

            <div class="floating-card score">
                <div class="float-label">⚡ Dokumen Diproses</div>
                <div class="float-value">247 <span>dokumen</span></div>
            </div>
        </div>
    </div>
</section>

{{-- ── STATS ── --}}
<section class="stats">
    <div class="stat-item reveal">
        <div class="stat-number">2.4<span class="accent">K+</span></div>
        <div class="stat-label">Pengguna Aktif</div>
    </div>
    <div class="stat-item reveal">
        <div class="stat-number">18<span class="accent">K+</span></div>
        <div class="stat-label">Dokumen Diproses</div>
    </div>
    <div class="stat-item reveal">
        <div class="stat-number">94<span class="accent">%</span></div>
        <div class="stat-label">Tingkat Kepuasan</div>
    </div>
    <div class="stat-item reveal">
        <div class="stat-number">4.8<span class="accent">★</span></div>
        <div class="stat-label">Rating Pengguna</div>
    </div>
</section>

{{-- ── FEATURES ── --}}
<section class="features" id="fitur">
    <div class="section-label">Fitur Unggulan</div>
    <h2 class="section-title">Semua yang Kamu<br>Butuhkan untuk Belajar</h2>
    <p class="section-desc">Dari dokumen mentah hingga pemahaman mendalam — semua dalam satu platform.</p>

    <div class="features-grid">
        <div class="feature-card reveal">
            <div class="feature-icon green">📄</div>
            <h3 class="feature-title">Upload Dokumen</h3>
            <p class="feature-desc">Unggah PDF, gambar, atau foto catatan. Leksika mendukung berbagai format dan memproses kontenmu secara otomatis.</p>
        </div>

        <div class="feature-card reveal">
            <div class="feature-icon teal">🤖</div>
            <h3 class="feature-title">Rangkuman AI</h3>
            <p class="feature-desc">Dapatkan ringkasan cerdas dari dokumenmu dalam hitungan detik. AI kami mengekstrak poin-poin penting yang relevan.</p>
        </div>

        <div class="feature-card reveal">
            <div class="feature-icon deep">🎯</div>
            <h3 class="feature-title">Kuis Otomatis</h3>
            <p class="feature-desc">Uji pemahamanmu dengan kuis yang dibuat langsung dari materi dokumenmu. Pilih jumlah soal sesuai kebutuhan.</p>
        </div>

        <div class="feature-card reveal">
            <div class="feature-icon teal">🔍</div>
            <h3 class="feature-title">OCR Cerdas</h3>
            <p class="feature-desc">Foto catatan tulisan tangan pun bisa diproses. Teknologi OCR kami mengubah gambar menjadi teks yang bisa dianalisis.</p>
        </div>

        <div class="feature-card reveal">
            <div class="feature-icon green">📊</div>
            <h3 class="feature-title">Riwayat Belajar</h3>
            <p class="feature-desc">Pantau progres belajarmu dari waktu ke waktu. Lihat dokumen yang sudah diproses dan hasil kuis sebelumnya.</p>
        </div>

        <div class="feature-card reveal">
            <div class="feature-icon deep">🔐</div>
            <h3 class="feature-title">Akun Aman</h3>
            <p class="feature-desc">Data dan dokumenmu terlindungi dengan autentikasi aman. Masuk dengan email atau Google — mudah dan cepat.</p>
        </div>
    </div>
</section>

{{-- ── HOW IT WORKS ── --}}
<section class="how" id="cara-kerja">
    <div class="how-inner">
        <div class="section-label" style="color: var(--teal-light);">Cara Kerja</div>
        <h2 class="section-title">Belajar Lebih Efektif<br>dalam 4 Langkah</h2>
        <p class="section-desc">Proses yang simpel, hasil yang luar biasa.</p>

        <div class="steps">
            <div class="step reveal">
                <div class="step-num">01</div>
                <h3 class="step-title">Daftar Akun</h3>
                <p class="step-desc">Buat akun gratis dalam 30 detik menggunakan email atau Google.</p>
            </div>
            <div class="step reveal">
                <div class="step-num">02</div>
                <h3 class="step-title">Upload Dokumen</h3>
                <p class="step-desc">Unggah PDF atau foto catatan belajarmu ke platform.</p>
            </div>
            <div class="step reveal">
                <div class="step-num">03</div>
                <h3 class="step-title">AI Memproses</h3>
                <p class="step-desc">Sistem kami menganalisis dan merangkum konten secara otomatis.</p>
            </div>
            <div class="step reveal">
                <div class="step-num">04</div>
                <h3 class="step-title">Belajar & Kuis</h3>
                <p class="step-desc">Baca rangkuman dan uji pemahaman dengan kuis yang sudah siap.</p>
            </div>
        </div>
    </div>
</section>

{{-- ── TESTIMONIALS ── --}}
<section class="testimonials" id="testimoni">
    <div class="testimonials-inner">
        <div class="section-label">Testimoni</div>
        <h2 class="section-title">Kata Mereka yang<br>Sudah Pakai Leksika</h2>
        <p class="section-desc" style="margin-bottom: 48px;">Ribuan pelajar sudah merasakan manfaatnya.</p>

        <div class="testi-grid">
            <div class="testi-card reveal">
                <div class="testi-stars">★★★★★</div>
                <p class="testi-text">"Leksika benar-benar mengubah cara belajarku. PDF 100 halaman bisa langsung dapat inti-intinya dalam 5 menit. Nilai UAS ku naik signifikan!"</p>
                <div class="testi-author">
                    <div class="testi-avatar" style="background: var(--green-accent);">AR</div>
                    <div>
                        <div class="testi-name">Ahmad Rizky</div>
                        <div class="testi-role">Mahasiswa Teknik Informatika</div>
                    </div>
                </div>
            </div>

            <div class="testi-card reveal">
                <div class="testi-stars">★★★★★</div>
                <p class="testi-text">"Fitur kuis otomatisnya luar biasa! Saya tidak perlu lagi buat soal latihan sendiri. Tinggal upload materi, langsung ada kuis-nya."</p>
                <div class="testi-author">
                    <div class="testi-avatar" style="background: var(--teal-mid);">SF</div>
                    <div>
                        <div class="testi-name">Siti Fatimah</div>
                        <div class="testi-role">Mahasiswa Kedokteran</div>
                    </div>
                </div>
            </div>

            <div class="testi-card reveal">
                <div class="testi-stars">★★★★☆</div>
                <p class="testi-text">"Sangat membantu untuk persiapan ujian. OCR-nya akurat banget, catatan tulisan tangan saya bisa terbaca dengan sempurna."</p>
                <div class="testi-author">
                    <div class="testi-avatar" style="background: var(--teal-deep);">BP</div>
                    <div>
                        <div class="testi-name">Budi Prasetyo</div>
                        <div class="testi-role">Pelajar SMA</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

{{-- ── CTA ── --}}
<section class="cta">
    <div class="cta-bg"></div>
    <div class="cta-inner reveal">
        <div class="section-label">Mulai Sekarang</div>
        <h2 class="section-title">Siap Belajar<br>Lebih Cerdas?</h2>
        <p class="cta-desc">Bergabung bersama ribuan pelajar yang sudah merasakan manfaat Leksika. Gratis untuk memulai.</p>
        <div class="cta-actions">
            <a href="#" class="btn-primary">Daftar Gratis →</a>
            <a href="#fitur" class="btn-secondary">Pelajari Lebih Lanjut</a>
        </div>
    </div>
</section>

{{-- ── FOOTER ── --}}
<footer>
    <div class="footer-brand">
        <a href="#" class="nav-logo">Leksi<span>ka</span></a>
        <p>Platform belajar cerdas yang mengubah dokumenmu menjadi pengetahuan yang bermakna dan terstruktur.</p>
    </div>

    <div class="footer-col">
        <h4>Produk</h4>
        <ul>
            <li><a href="#">Fitur</a></li>
            <li><a href="#">Cara Kerja</a></li>
            <li><a href="#">Harga</a></li>
            <li><a href="#">Changelog</a></li>
        </ul>
    </div>

    <div class="footer-col">
        <h4>Perusahaan</h4>
        <ul>
            <li><a href="#">Tentang Kami</a></li>
            <li><a href="#">Blog</a></li>
            <li><a href="#">Karir</a></li>
            <li><a href="#">Kontak</a></li>
        </ul>
    </div>

    <div class="footer-col">
        <h4>Legal</h4>
        <ul>
            <li><a href="#">Kebijakan Privasi</a></li>
            <li><a href="#">Syarat Layanan</a></li>
            <li><a href="#">Cookie</a></li>
        </ul>
    </div>
</footer>

<div class="footer-bottom">
    <p>© {{ date('Y') }} Leksika. Dibuat dengan ❤️ untuk pelajar Indonesia.</p>
    <p>Versi 1.0.0</p>
</div>

<script>
    // ── SCROLL REVEAL ──
    const reveals = document.querySelectorAll('.reveal');
    const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry, i) => {
            if (entry.isIntersecting) {
                setTimeout(() => entry.target.classList.add('visible'), i * 80);
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });
    reveals.forEach(el => observer.observe(el));

    // ── NAVBAR SCROLL EFFECT ──
    const nav = document.querySelector('nav');
    window.addEventListener('scroll', () => {
        nav.style.boxShadow = window.scrollY > 50
            ? '0 4px 24px rgba(30,63,57,0.1)'
            : 'none';
    });

    // ── SMOOTH SCROLL ──
    document.querySelectorAll('a[href^="#"]').forEach(a => {
        a.addEventListener('click', e => {
            const target = document.querySelector(a.getAttribute('href'));
            if (target) {
                e.preventDefault();
                target.scrollIntoView({ behavior: 'smooth' });
            }
        });
    });
</script>

</body>
</html>