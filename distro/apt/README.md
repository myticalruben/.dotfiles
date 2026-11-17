# Repo APT local de Mytical

Genera un repositorio APT firmado a partir de los `.deb` que produce
`make -C distro packages` en `distro/build/`. La salida vive en
`distro/apt/public/` y **no se versiona**.

## Herramienta elegida

`apt-ftparchive` (paquete `apt-utils`). Fue la opción disponible en este
entorno; `reprepro` no está instalado, así que no se usa. `apt-ftparchive`
genera `Packages`, `Packages.gz` y `Release` con checksums SHA256/SHA512.

Comprobación:

```bash
command -v apt-ftparchive
apt-ftparchive --version          # aquí: apt 3.0.4
command -v gpg gpgv               # firma y verificación
```

Dependencias en Ubuntu 26.04:

```bash
sudo apt install apt-utils gnupg dpkg python3 gzip make
```

- `apt-utils` → `apt-ftparchive`
- `gnupg` → `gpg` y `gpgv`
- `dpkg` → `dpkg-deb`
- `python3` → solo lo usa el test para servir el repo por HTTP
- `gzip`, `make`

> En el entorno de desarrollo actual (Debian 13) `apt-ftparchive` está
> instalado, pero `gpg`/`gpgv` no están en el sistema; el test detecta
> GnuPG en `/nix/store/*-gnupg-*/bin` y lo usa. En Ubuntu 26.04 basta con
> instalar `gnupg`.

## Uso

```bash
# 1. Paquetes (los targets de distro/ ya existen)
make -C distro packages

# 2. Repo sin firmar
make -C distro/apt repo

# 3. Firmar. GPG_KEY es fingerprint o uid de una clave sin passphrase.
make -C distro/apt sign GPG_KEY=apt@mytical.invalid

# 4. Prueba end-to-end (root APT temporal, sin tocar el host)
make -C distro/apt test

# Limpiar public/
make -C distro/apt clean
```

`sign` vuelve a construir el repo antes de firmar (`sign: repo`). No pide
passphrase: usa `gpg --batch`; la clave debe estar sin passphrase o ya
desbloqueada por `gpg-agent`. **Nunca** se guarda una clave privada en el
repo.

Si quieres usar una clave concreta:

```bash
export GNUPGHOME="$HOME/.gnupg-mytical-apt"   # opcional
gpg --list-secret-keys --keyid-format=long
make -C distro/apt sign GPG_KEY=<fingerprint>
```

## Estructura generada

```text
distro/apt/public/
├── dists/mytical/
│   ├── InRelease                         # Release firmado en claro (lo usa APT)
│   ├── Release                           # metadatos + checksums
│   ├── Release.gpg                       # firma detached de Release
│   └── main/binary-amd64/
│       ├── Packages
│       └── Packages.gz
└── pool/main/m/
    ├── mytical-desktop/
    │   └── mytical-desktop_0.1.0-1~resolute1_all.deb
    └── mytical-session/
        └── mytical-session_0.1.0-1~resolute1_all.deb
```

- `Packages.gz` es la versión comprimida de `Packages` (`gzip -9n`, sin
  timestamp) y APT puede pedir cualquiera de las dos.
- `Release` incluye `Origin`, `Label`, `Suite: mytical`, `Codename:
  mytical`, `Architectures: amd64`, `Components: main` y los checksums de
  `Packages`/`Packages.gz`.
- `InRelease` es `Release` con firma en claro; APT lo prefiere.
  `Release.gpg` es la firma detached de respaldo.
- El `pool/` conserva el nombre exacto del `.deb`; `Filename` en
  `Packages` es relativo a la raíz servida (`pool/main/...`).

Los `.deb` se copian sin recomprimir. Cambiar un paquete exige
`make repo`/`make sign` de nuevo: si se firma y luego se reconstruye, la
firma queda obsoleta.

## Cliente APT (sources.list deb822)

Sirve `public/`, por ejemplo:

```bash
python3 -m http.server 8080 --directory distro/apt/public
```

Copia la clave pública al llavero del sistema (formato armored o binario;
APT acepta ambos en `Signed-By`):

```bash
gpg --armor --export apt@mytical.invalid | sudo tee /usr/share/keyrings/mytical-apt.asc >/dev/null
```

Crea `/etc/apt/sources.list.d/mytical.sources`:

```text
Types: deb
URIs: http://127.0.0.1:8080
Suites: mytical
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/mytical-apt.asc
```

Y usa APT normal:

```bash
sudo apt-get update
apt-cache policy mytical-session
sudo apt-get install mytical-session
```

`URIs` debe apuntar a la raíz que contiene `dists/` y `pool/` (aquí
`public/`). `Signed-By` limita la confianza a esa clave; no hace falta
`trusted=yes`.

## Test

```bash
bash distro/tests/test_apt_repo.sh
# o
make -C distro/apt test
```

El test:

1. construye los paquetes si faltan;
2. genera `public/` con `apt-ftparchive`;
3. crea una clave GPG **efímera** (RSA 3072, 1 día, sin passphrase) y firma
   `Release`/`InRelease` si hay `gpg` y `gpgv`;
4. sirve `public/` con `python3 -m http.server` en `127.0.0.1:<puerto libre>`;
5. crea un root APT temporal (`Dir=<tmp>/apt-root`, listas, cache, status y
   configuración propios) y ejecuta `apt-get update` ahí; **no toca el APT
   del host**;
6. comprueba `Package: mytical-session`, que el candidato viene del repo de
   prueba y que `apt-get download` baja exactamente el `.deb` generado.

Si no hay `gpg`/`gpgv`, el test continúa con el repo sin firmar y
`Trusted: yes`, y deja un `SKIP:` explícito; no simula una firma. Si falta
`apt-ftparchive`, `python3`, `dpkg-deb`, `apt-get`, `gzip` o `make`, sale
con código 77 (`SKIP`). El test deja `public/` construido (ignorado por git);
`make clean` lo borra. Ese `public/` está firmado con la clave efímera, que se
borra al terminar: sirve para inspeccionar la estructura, no como repo de
producción. Para un repo usable, firma con tu clave (`make sign GPG_KEY=...`).

## Reproducibilidad

- Los `.deb` vienen del target `make -C distro packages`
  (`dpkg-deb --build --root-owner-group`), no se regeneran ni se modifican.
- `Packages.gz` usa `gzip -9n`, sin nombre ni mtime.
- `Release` lo escribe `apt-ftparchive` con `Date` actual y firmas con
  timestamp: la estructura y los checksums son reproducibles, pero no se
  promete una firma byte a byte idéntica entre ejecuciones.
- `distro/apt/public/` está en `.gitignore`; no se versionan binarios ni
  índices generados.
