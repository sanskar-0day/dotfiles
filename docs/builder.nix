{
  lib,
  runCommand,
  typst,
}:

let
  # ── Read all config files ────────────────────────────────────
  f = {
    flake = builtins.readFile (toString ../flake.nix);
    host = builtins.readFile (toString ../hosts/nixos/default.nix);
    hardware = builtins.readFile (toString ../hosts/nixos/hardware.nix);
    boot = builtins.readFile (toString ../modules/boot.nix);
    desktop = builtins.readFile (toString ../modules/desktop.nix);
    nvidia = builtins.readFile (toString ../modules/nvidia.nix);
    gaming = builtins.readFile (toString ../modules/gaming.nix);
    ai = builtins.readFile (toString ../modules/ai.nix);
    typstMod = builtins.readFile (toString ../modules/typst.nix);
    virt = builtins.readFile (toString ../modules/virtualization.nix);
    userDef = builtins.readFile (toString ../home/sanskar/default.nix);
    shell = builtins.readFile (toString ../home/sanskar/shell.nix);
    git = builtins.readFile (toString ../home/sanskar/git.nix);
    tools = builtins.readFile (toString ../home/sanskar/tools.nix);
    nvim = builtins.readFile (toString ../home/sanskar/nvim.nix);
    dev = builtins.readFile (toString ../home/sanskar/dev.nix);
  };

  # ── Typst document template ──────────────────────────────────
  # Using regular "..." string so Nix interpolation works.
  # Code blocks use ```nix ... ``` (raw blocks) so Typst treats
  # # characters as literal (not code markers).
  # $ is escaped as \$ for Typst, and ] is escaped as \].
  typstDoc = ''
                    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    //   NixOS Configuration Reference — Auto-generated
                    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

                #set page(
                  paper: "a4",
                      margin: (left: 2.2cm, right: 2.2cm, top: 2.5cm, bottom: 2.5cm),
                      numbering: "1",
                      header: context {
                        if counter(page).get().first() > 1 [
                          #set text(8pt, fill: luma(140))
                          #smallcaps[NixOS Configuration]
                          #h(1fr)
                          #counter(page).display("--- 1 ---")
                          #line(length: 100%, stroke: 0.3pt + luma(200))
                        ]
                      },
                      footer: context {
                        if counter(page).get().first() > 1 [
                          #set text(8pt, fill: luma(140))
                          #line(length: 100%, stroke: 0.3pt + luma(200))
                          #h(1fr)
                          #counter(page).display()
                          #h(1fr)
                        ]
                      },
                    )

                    #set text(font: "Libertinus Serif", size: 10.5pt, fill: luma(30))
                    #set par(justify: true, leading: 0.65em)
    #set raw(lang: "nix")
    #show raw.where(block: true): set text(font: "JetBrains Mono", size: 7.5pt)
            #show heading.where(level: 1): it => {
              text(size: 22pt, weight: "bold")[#it.body]
              v(0.5cm)
            }


                    // ═══════════════════════════════════════════════════════════════
                    //   TITLE PAGE
                    // ═══════════════════════════════════════════════════════════════

                    #v(3cm)

                    #align(center)[
                      #block(
                        width: 85%,
                        inset: (x: 2cm, y: 1.5cm),
                        radius: 8pt,
                        stroke: 1pt + rgb("#6272a4"),
                        fill: luma(252),
                      )[
                        #text(size: 32pt, weight: "bold", fill: rgb("#282a36"))[NixOS Configuration]
                        #v(0.3cm)
                        #line(length: 60%, stroke: 0.8pt + rgb("#6272a4"))
                        #v(0.3cm)
                        #text(size: 18pt, fill: rgb("#6272a4"))[Complete Reference Guide]
                        #v(0.5cm)
                        #text(size: 11pt, style: "italic", fill: luma(120))[
                          Auto-generated from flake source \
                          March 18, 2026
                        ]
                      ]

                      #v(2cm)

                      #block(width: 70%, inset: 0.8cm, radius: 4pt, fill: luma(250))[
                        #set text(size: 10pt, fill: luma(80))
                        #grid(
                          columns: (1fr, 1fr),
                          gutter: 0.6cm,
                          [NixOS *25.11*], [Kernel *6.12*],
                          [Home Manager], [KDE Plasma 6],
                          [NVIDIA PRIME], [systemd-boot],
                        )
                      ]
                    ]

                    #v(1fr)

                    #align(center)[
                      #set text(size: 9pt, fill: luma(160))
                      Sanskar's dotfiles \
                      github.com/Sanskar-0day/dotfiles
                    ]

                    #pagebreak(weak: true)


                    // ═══════════════════════════════════════════════════════════════
                    //   TABLE OF CONTENTS
                    // ═══════════════════════════════════════════════════════════════

                    #v(2cm)
                    #align(center)[
                      #text(size: 20pt, weight: "bold", fill: rgb("#282a36"))[Contents]
                    ]
                    #v(1cm)
                    #outline(title: none, indent: 1.2em, depth: 2)
                    #pagebreak(weak: true)


                    // ═══════════════════════════════════════════════════════════════
                    //   1. FLAKE
                    // ═══════════════════════════════════════════════════════════════

                    #heading(level: 1)[Flake Structure]
                    #v(0.3cm)

                    #block(
                      width: 100%,
                      inset: 12pt,
                      radius: 4pt,
                      stroke: 0.6pt + rgb("#50fa7b"),
                      fill: rgb("#50fa7b").lighten(92%),
                    )[
                      #text(weight: "bold", fill: rgb("#50fa7b").darken(30%))[$\u{2139}$ What is this?]
                      #v(2pt)
                      The flake is the top-level entry point. It pins `nixpkgs` (stable + unstable),
                      wires Home Manager as a NixOS module, and exposes `nixosConfigurations.nixos`
                      and `homeConfigurations.sanskar`.
                    ]

                    ```nix
                    ${f.flake}
                    ```


                    // ═══════════════════════════════════════════════════════════════
                    //   2. HOST CONFIGURATION
                    // ═══════════════════════════════════════════════════════════════

                    #heading(level: 1)[Host Configuration]
                    #v(0.3cm)

                    #heading(level: 2)[hosts/nixos/default.nix — System]

                    ```nix
                    ${f.host}
                    ```

                    #heading(level: 2)[hosts/nixos/hardware.nix — Hardware]

                    ```nix
                    ${f.hardware}
                    ```


                    // ═══════════════════════════════════════════════════════════════
                    //   3. MODULES
                    // ═══════════════════════════════════════════════════════════════

                    #heading(level: 1)[Modules]
                    #v(0.3cm)

                    #heading(level: 2)[modules/boot.nix — Boot & Power]
                    ```nix
                    ${f.boot}
                    ```

                    #heading(level: 2)[modules/desktop.nix — KDE Plasma 6]
                    ```nix
                    ${f.desktop}
                    ```

                    #heading(level: 2)[modules/nvidia.nix — NVIDIA GPU]
                    ```nix
                    ${f.nvidia}
                    ```

                    #heading(level: 2)[modules/gaming.nix — Gaming]
                    ```nix
                    ${f.gaming}
                    ```

                    #heading(level: 2)[modules/ai.nix — AI Infrastructure]
                    ```nix
                    ${f.ai}
                    ```

                    #heading(level: 2)[modules/typst.nix — Typst Ecosystem]
                    ```nix
                    ${f.typstMod}
                    ```

                    #heading(level: 2)[modules/virtualization.nix — Docker & VMs]
                    ```nix
                    ${f.virt}
                    ```


                    // ═══════════════════════════════════════════════════════════════
                    //   4. HOME MANAGER
                    // ═══════════════════════════════════════════════════════════════

                    #heading(level: 1)[Home Manager]
                    #v(0.3cm)

                    #heading(level: 2)[home/sanskar/default.nix — User Config]
                    ```nix
                    ${f.userDef}
                    ```

                    #heading(level: 2)[home/sanskar/shell.nix — Zsh + Starship]
                    ```nix
                    ${f.shell}
                    ```

                    #heading(level: 2)[home/sanskar/git.nix — Git + Delta]
                    ```nix
                    ${f.git}
                    ```

                    #heading(level: 2)[home/sanskar/tools.nix — CLI Tools]
                    ```nix
                    ${f.tools}
                    ```

                    #heading(level: 2)[home/sanskar/nvim.nix — Neovim]
                    ```nix
                    ${f.nvim}
                    ```

                    #heading(level: 2)[home/sanskar/dev.nix — Development]
                    ```nix
                    ${f.dev}
                    ```
  '';

in
runCommand "nixos-config-docs"
  {
    nativeBuildInputs = [ typst ];
  }
  ''
    mkdir -p $out
    cp ${builtins.toFile "config-reference.typ" typstDoc} config-reference.typ
    typst compile config-reference.typ $out/config-reference.pdf
    cp config-reference.typ $out/
    echo "Built config-reference.pdf"
  ''
