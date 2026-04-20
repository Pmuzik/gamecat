<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:gc="http://pmuzik.github.io/gamecat/"
  exclude-result-prefixes="gc">

  <xsl:output method="html" version="5.0" encoding="UTF-8" indent="yes"
    doctype-system="about:legacy-compat"/>

  <!-- ============================================================
       ROOT TEMPLATE
  ============================================================ -->
  <xsl:template match="/gc:game">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>
          <xsl:value-of select="gc:titles/gc:title[@type='primary' and @lang='en']"/>
          <xsl:if test="not(gc:titles/gc:title[@type='primary' and @lang='en'])">
            <xsl:value-of select="gc:titles/gc:title[@type='primary'][1]"/>
          </xsl:if>
          <xsl:text> — Game Record</xsl:text>
        </title>
        <link rel="preconnect" href="https://fonts.googleapis.com"/>
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin=""/>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;0,900;1,700&amp;family=IBM+Plex+Mono:wght@400;500&amp;family=Lora:ital,wght@0,400;0,600;1,400&amp;display=swap" rel="stylesheet"/>
        <style>
          /* ── Reset &amp; base ───────────────────────────────────── */
          *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

          :root {
            --ink:        #1c1410;
            --ink-mid:    #5a4a3a;
            --ink-faint:  #9e8a78;
            --paper:      #f5efe4;
            --paper-dark: #ede4d5;
            --accent:     #b84c1e;
            --accent-dim: #d4855e;
            --gold:       #c9933a;
            --verified:   #2d6a4f;
            --unverified: #8b6f2e;
            --border:     #c8b89a;
          }

          html { background: var(--paper-dark); }

          body {
            font-family: 'Lora', Georgia, serif;
            color: var(--ink);
            background: var(--paper);
            min-height: 100vh;
            padding: 2rem 1rem 4rem;
            /* Subtle paper texture via SVG noise */
            background-image:
              url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='300' height='300'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.75' numOctaves='4' stitchTiles='stitch'/%3E%3CfeColorMatrix type='saturate' values='0'/%3E%3C/filter%3E%3Crect width='300' height='300' filter='url(%23n)' opacity='0.035'/%3E%3C/svg%3E");
          }

          /* ── Page shell ───────────────────────────────────────── */
          .page {
            max-width: 760px;
            margin: 0 auto;
          }

          /* ── Header ───────────────────────────────────────────── */
          .game-header {
            border-top: 4px solid var(--ink);
            border-bottom: 1px solid var(--border);
            padding: 2.5rem 0 2rem;
            margin-bottom: 2.5rem;
            position: relative;
          }

          .game-header::after {
            content: '';
            display: block;
            height: 3px;
            background: repeating-linear-gradient(
              90deg,
              var(--accent) 0px, var(--accent) 6px,
              transparent 6px, transparent 10px
            );
            margin-top: 1.5rem;
          }

          .platform-badge {
            display: inline-block;
            font-family: 'IBM Plex Mono', monospace;
            font-size: 0.65rem;
            font-weight: 500;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            color: var(--accent);
            border: 1.5px solid var(--accent);
            padding: 0.2em 0.6em;
            margin-bottom: 1rem;
          }

          .primary-title-ja {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 0.85rem;
            color: var(--ink-mid);
            margin-bottom: 0.3rem;
            letter-spacing: 0.04em;
          }

          .primary-title-en {
            font-family: 'Playfair Display', Georgia, serif;
            font-size: clamp(2rem, 5vw, 3.2rem);
            font-weight: 900;
            line-height: 1.05;
            color: var(--ink);
            margin-bottom: 0.5rem;
          }

          .title-localized-note {
            font-family: 'Lora', serif;
            font-size: 0.82rem;
            font-style: italic;
            color: var(--ink-faint);
          }

          /* ── Two-column info grid ─────────────────────────────── */
          .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 0;
            border: 1px solid var(--border);
            margin-bottom: 2.5rem;
          }

          .info-cell {
            padding: 1rem 1.2rem;
            border-bottom: 1px solid var(--border);
            border-right: 1px solid var(--border);
          }

          .info-cell:nth-child(2n) { border-right: none; }
          .info-cell:nth-last-child(-n+2) { border-bottom: none; }

          .info-label {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 0.6rem;
            letter-spacing: 0.14em;
            text-transform: uppercase;
            color: var(--ink-faint);
            margin-bottom: 0.35rem;
          }

          .info-value {
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--ink);
          }

          .authority-link {
            color: var(--ink);
            text-decoration: none;
            border-bottom: 1px dotted var(--accent-dim);
            transition: color 0.15s, border-color 0.15s;
          }
          .authority-link:hover {
            color: var(--accent);
            border-bottom-color: var(--accent);
          }

          /* ── Section ──────────────────────────────────────────── */
          .section {
            margin-bottom: 2.5rem;
          }

          .section-heading {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 0.65rem;
            letter-spacing: 0.18em;
            text-transform: uppercase;
            color: var(--accent);
            padding-bottom: 0.5rem;
            border-bottom: 1px solid var(--border);
            margin-bottom: 1.2rem;
            display: flex;
            align-items: center;
            gap: 0.6rem;
          }

          .section-heading::before {
            content: '▪';
            color: var(--accent);
          }

          /* ── Releases ─────────────────────────────────────────── */
          .releases-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
          }

          .release-item {
            display: flex;
            align-items: baseline;
            gap: 1rem;
            padding: 0.6rem 0.9rem;
            background: var(--paper-dark);
            border-left: 3px solid var(--gold);
          }

          .release-date {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 0.85rem;
            color: var(--ink);
            white-space: nowrap;
            font-weight: 500;
          }

          .release-region {
            font-size: 0.9rem;
            color: var(--ink-mid);
          }

          /* ── Credits ──────────────────────────────────────────── */
          .credits-table {
            width: 100%;
            border-collapse: collapse;
          }

          .credits-table thead tr {
            background: var(--ink);
            color: var(--paper);
          }

          .credits-table thead th {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 0.6rem;
            letter-spacing: 0.14em;
            text-transform: uppercase;
            font-weight: 500;
            text-align: left;
            padding: 0.6rem 0.9rem;
          }

          .credits-table tbody tr {
            border-bottom: 1px solid var(--border);
            transition: background 0.1s;
          }

          .credits-table tbody tr:hover {
            background: var(--paper-dark);
          }

          .credits-table td {
            padding: 0.6rem 0.9rem;
            font-size: 0.9rem;
          }

          .credit-role {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 0.72rem;
            color: var(--ink-mid);
            text-transform: capitalize;
            white-space: nowrap;
          }

          .credit-name {
            color: var(--ink);
          }

          .credit-name a {
            color: var(--ink);
            text-decoration: none;
            border-bottom: 1px dotted var(--accent-dim);
          }
          .credit-name a:hover {
            color: var(--accent);
            border-bottom-color: var(--accent);
          }

          .verified-badge {
            display: inline-block;
            font-family: 'IBM Plex Mono', monospace;
            font-size: 0.6rem;
            letter-spacing: 0.06em;
            padding: 0.1em 0.4em;
            border-radius: 2px;
            margin-left: 0.5rem;
            vertical-align: middle;
          }

          .verified-badge.yes {
            background: #d8f0e5;
            color: var(--verified);
            border: 1px solid #a8d8bf;
          }

          .verified-badge.no {
            background: #f5ecd5;
            color: var(--unverified);
            border: 1px solid #dfd0a8;
          }

          /* ── Titles section ───────────────────────────────────── */
          .titles-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 0.4rem;
          }

          .title-item {
            display: flex;
            align-items: baseline;
            gap: 0.8rem;
            padding: 0.5rem 0.9rem;
            border-bottom: 1px solid var(--border);
          }

          .title-item:last-child { border-bottom: none; }

          .title-type-tag {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 0.6rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: var(--paper);
            background: var(--ink-mid);
            padding: 0.15em 0.45em;
            border-radius: 2px;
            white-space: nowrap;
            flex-shrink: 0;
          }

          .title-type-tag.primary { background: var(--accent); }
          .title-type-tag.localized { background: var(--gold); }
          .title-type-tag.variant { background: var(--ink-faint); }

          .title-lang-tag {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 0.65rem;
            color: var(--ink-faint);
            white-space: nowrap;
            flex-shrink: 0;
          }

          .title-text {
            font-size: 0.95rem;
            color: var(--ink);
          }

          /* ── Footer ───────────────────────────────────────────── */
          .record-footer {
            margin-top: 3rem;
            padding-top: 1rem;
            border-top: 1px solid var(--border);
            font-family: 'IBM Plex Mono', monospace;
            font-size: 0.62rem;
            color: var(--ink-faint);
            letter-spacing: 0.06em;
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 0.5rem;
          }

          @media (max-width: 520px) {
            .info-cell:nth-child(2n) { border-right: 1px solid var(--border); }
            .info-grid { grid-template-columns: 1fr; }
            .info-cell { border-right: none !important; }
            .info-cell:last-child { border-bottom: none; }
          }
        </style>
      </head>
      <body>
        <div class="page">

          <!-- ── HEADER ─────────────────────────────────────────── -->
          <header class="game-header">
            <div class="platform-badge">
              <xsl:value-of select="gc:platform"/>
            </div>

            <!-- Romanized Japanese title as display subtitle -->
            <xsl:variable name="ja-latn" select="gc:titles/gc:title[@lang='ja' and @script='Latn']"/>
            <xsl:if test="$ja-latn">
              <p class="primary-title-ja">
                <xsl:value-of select="$ja-latn"/>
              </p>
            </xsl:if>

            <!-- Prefer English localized/primary title as the big heading -->
            <xsl:variable name="en-title" select="gc:titles/gc:title[@lang='en']"/>
            <h1 class="primary-title-en">
              <xsl:choose>
                <xsl:when test="$en-title">
                  <xsl:value-of select="$en-title"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="gc:titles/gc:title[@type='primary'][1]"/>
                </xsl:otherwise>
              </xsl:choose>
            </h1>

            <!-- Note if the displayed title is a localization -->
            <xsl:if test="gc:titles/gc:title[@lang='en' and @type='localized']">
              <p class="title-localized-note">
                <xsl:text>Known in Japan as </xsl:text>
                <xsl:value-of select="gc:titles/gc:title[@lang='ja' and @script='Jpan']"/>
              </p>
            </xsl:if>
          </header>

          <!-- ── INFO GRID ──────────────────────────────────────── -->
          <div class="info-grid">

            <div class="info-cell">
              <p class="info-label">Developer</p>
              <p class="info-value">
                <xsl:call-template name="authority-value">
                  <xsl:with-param name="node" select="gc:developer"/>
                </xsl:call-template>
              </p>
            </div>

            <div class="info-cell">
              <p class="info-label">Publisher</p>
              <p class="info-value">
                <xsl:call-template name="authority-value">
                  <xsl:with-param name="node" select="gc:publisher"/>
                </xsl:call-template>
              </p>
            </div>

            <div class="info-cell">
              <p class="info-label">Genre</p>
              <p class="info-value"><xsl:value-of select="gc:genre"/></p>
            </div>

            <div class="info-cell">
              <p class="info-label">Players</p>
              <p class="info-value"><xsl:value-of select="gc:players"/></p>
            </div>

          </div>

          <!-- ── TITLES ─────────────────────────────────────────── -->
          <section class="section">
            <h2 class="section-heading">All Titles</h2>
            <ul class="titles-list">
              <xsl:for-each select="gc:titles/gc:title">
                <li class="title-item">
                  <span>
                    <xsl:attribute name="class">
                      <xsl:text>title-type-tag </xsl:text>
                      <xsl:value-of select="@type"/>
                    </xsl:attribute>
                    <xsl:value-of select="@type"/>
                  </span>
                  <span class="title-lang-tag">
                    <xsl:value-of select="@lang"/>
                    <xsl:if test="@script">
                      <xsl:text> / </xsl:text>
                      <xsl:value-of select="@script"/>
                    </xsl:if>
                  </span>
                  <span class="title-text">
                    <xsl:value-of select="."/>
                  </span>
                </li>
              </xsl:for-each>
            </ul>
          </section>

          <!-- ── RELEASES ───────────────────────────────────────── -->
          <section class="section">
            <h2 class="section-heading">Release History</h2>
            <ul class="releases-list">
              <xsl:for-each select="gc:releases/gc:release">
                <xsl:sort select="gc:date"/>
                <li class="release-item">
                  <span class="release-date">
                    <xsl:value-of select="gc:date"/>
                  </span>
                  <span class="release-region">
                    <xsl:value-of select="gc:region"/>
                  </span>
                </li>
              </xsl:for-each>
            </ul>
          </section>

          <!-- ── CREDITS ────────────────────────────────────────── -->
          <section class="section">
            <h2 class="section-heading">Credits</h2>
            <table class="credits-table">
              <thead>
                <tr>
                  <th>Role</th>
                  <th>Name</th>
                  <th>Authority</th>
                </tr>
              </thead>
              <tbody>
                <xsl:for-each select="gc:credits/gc:credit">
                  <xsl:sort select="@role"/>
                  <tr>
                    <td class="credit-role">
                      <xsl:value-of select="@role"/>
                    </td>
                    <td class="credit-name">
                      <xsl:choose>
                        <xsl:when test="@authority-uri">
                          <a>
                            <xsl:attribute name="href">
                              <xsl:value-of select="@authority-uri"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <xsl:attribute name="rel">noopener noreferrer</xsl:attribute>
                            <xsl:value-of select="."/>
                          </a>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="."/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </td>
                    <td>
                      <xsl:choose>
                        <xsl:when test="@authority-source">
                          <span class="verified-badge yes">
                            <xsl:value-of select="@authority-source"/>
                          </span>
                        </xsl:when>
                        <xsl:when test="@authority-verified = 'false'">
                          <span class="verified-badge no">unverified</span>
                        </xsl:when>
                        <xsl:otherwise>
                          <span class="verified-badge no">unverified</span>
                        </xsl:otherwise>
                      </xsl:choose>
                    </td>
                  </tr>
                </xsl:for-each>
              </tbody>
            </table>
          </section>

          <!-- ── FOOTER ─────────────────────────────────────────── -->
          <footer class="record-footer">
            <span>Namespace: http://pmuzik.github.io/gamecat/</span>
            <span>Schema: <a style="color:inherit" href="gamecat_1_0.xsd">gamecat_1_0.xsd</a></span>
            <span>
              <a style="color:inherit">
                <xsl:attribute name="href">
                  <xsl:value-of select="@id"/>
                  <xsl:text>.xml</xsl:text>
                </xsl:attribute>
                Source: <xsl:value-of select="@id"/>.xml
              </a>
            </span>
          </footer>

        </div><!-- /.page -->
      </body>
    </html>
  </xsl:template>

  <!-- ============================================================
       NAMED TEMPLATE: authority-value
       Renders a node's text content as a link if @authority-uri
       is present, otherwise as plain text.
  ============================================================ -->
  <xsl:template name="authority-value">
    <xsl:param name="node"/>
    <xsl:choose>
      <xsl:when test="$node/@authority-uri">
        <a class="authority-link">
          <xsl:attribute name="href">
            <xsl:value-of select="$node/@authority-uri"/>
          </xsl:attribute>
          <xsl:attribute name="target">_blank</xsl:attribute>
          <xsl:attribute name="rel">noopener noreferrer</xsl:attribute>
          <xsl:value-of select="$node"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$node"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
