---
name: write-nix
description: "Use whenever writing or generating Nix code: .nix files, flakes, shell.nix/default.nix, NixOS modules and configurations, packaging, dev shells, cross compilation, CI/binary caches."
---

# Write Nix

Write idiomatic, reproducible Nix following nix.dev guidance. Consult the bundled resources before generating non-trivial code; they are markdown mirrors of nix.dev tutorials, guides, and recipes.

## Workflow

1. Identify the kind of code, read the matching resource file first:
   - Language syntax/semantics → `resources/nix-language.md`
   - Packaging software → `resources/packaging-existing-software.md`
   - Parametrising/overriding packages → `resources/callpackage.md`
   - Local sources in derivations → `resources/working-with-local-files.md`
   - Targeting another platform → `resources/cross-compilation.md`
   - Dev shells, direnv, binary caches, CI, Python envs, npins, post-build hooks → `resources/recipes/<topic>.md`
   - NixOS VMs, images, testing, deployment, caches, remote builders → `resources/nixos/<topic>.md`
2. Apply `resources/best-practices.md` hard rules (below). They override habit and upstream copy-paste.
3. On build/eval failures, check `resources/troubleshooting.md` before improvising workarounds.

## Hard rules

- Quote URLs: `"https://example.com"`, never bare `https://example.com`.
- Avoid `rec`. Use `let ... in`. For self-reference, name the set explicitly (`let argset = { ... argset.a ... }; in argset`).
 - Prefer `with pkgs; [ ... ]` for package lists (`packages`, `buildInputs`, etc). It reads better than spelling `pkgs.` on every entry. Only fall back to explicit `inherit (pkgs) ...` / `builtins.attrValues { inherit (pkgs) ...; }` when static analysis is absolutely necessary. Still never `with` an entire import at the top of a file (`with (import <nixpkgs> {});`) — scope `with pkgs` to small list expressions with `pkgs` bound in a `let`.
- No `<...>` lookup paths (e.g. `<nixpkgs>`) except in throwaway minimal examples. Pin Nixpkgs explicitly (fetchTarball/npins/flake lock) and, on NixOS, set `nix.nixPath` centrally if a tool demands a lookup path.
- Always set `config` and `overlays` when importing Nixpkgs: `import nixpkgs { config = {}; overlays = []; }`.
- Nested attrset merge: use `lib.recursiveUpdate`, not `//` (shallow, drops sibling keys).
- Local `src`: use `builtins.path { path = ./.; name = "<fixed-name>"; }` (or `lib.fileset` per `resources/working-with-local-files.md`), never bare `src = ./.;` — the parent directory name otherwise leaks into the store path.
- Share package deps with dev shells via `inputsFrom`: define `shell = pkgs.mkShellNoCC { inputsFrom = [ myPackage ]; ...; }` in `default.nix`, import it from `shell.nix` as `(import ./.).shell` or `(import ./. {}).shell` when `default.nix` is a function.

## Resources index

- `resources/nix-language.md` — Nix language basics
- `resources/packaging-existing-software.md` — Packaging existing software
- `resources/callpackage.md` — Package parameters and overrides with callPackage
- `resources/working-with-local-files.md` — Working with local files (lib.fileset)
- `resources/cross-compilation.md` — Cross compilation (pkgsCross, crossSystem)
- `resources/best-practices.md` — Best practices (source of Hard rules)
- `resources/troubleshooting.md` — Troubleshooting (binary cache, DB corruption, schema mismatch)
- `resources/recipes/` — add-binary-cache, direnv, sharing-dependencies, dependency-management (npins), python-environment, post-build-hook, continuous-integration-github-actions
- `resources/nixos/` — nixos-configuration-on-vm, building-bootable-iso-image, building-and-running-docker-images, integration-testing-using-virtual-machines, provisioning-remote-machines, installing-nixos-on-a-raspberry-pi, deploying-nixos-using-terraform, binary-cache-setup, distributed-builds-setup

All resources carry `Source:` (rendered nix.dev page) and `Upstream:` (nix.dev repo path) headers. Re-scrape from `https://nix.dev/_sources/<path>.md` when refreshing.
