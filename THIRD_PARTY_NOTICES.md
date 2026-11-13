# Licensing and third-party notices

Copyright (C) 2026 Eugene (phys-winner).

Original code and porting tools contributed by this project are licensed under
the GNU General Public License, version 3 or (at your option) any later version
(`GPL-3.0-or-later`). The complete license is in [LICENSE](LICENSE).

External dependencies retain their own copyright notices and licenses. Their
code is downloaded into the ignored build cache and is not part of this
repository. The full license texts are included in those downloaded sources:

| Component | Source / version | License text |
| --- | --- | --- |
| Dynarmic | [azahar-emu/dynarmic](https://github.com/azahar-emu/dynarmic), revision `e77b1ba0b7da7cbe93021b01a663acfe7c4dd516`, with local ARM64 backend changes | [0BSD](https://github.com/azahar-emu/dynarmic/blob/e77b1ba0b7da7cbe93021b01a663acfe7c4dd516/LICENSE.txt) |
| Boost headers | 1.83.0 | [Boost Software License 1.0](https://www.boost.org/LICENSE_1_0.txt) |
| fmt | `7b273fbb541c7c9058800bc613f4291274b2d26e` (Dynarmic submodule) | [MIT and optional exception](https://github.com/fmtlib/fmt/blob/7b273fbb541c7c9058800bc613f4291274b2d26e/LICENSE) |
| mcl | `5fc4beaf331037649b10625736b41365defb4f50` (Dynarmic submodule) | [MIT](https://github.com/azahar-emu/mcl/blob/5fc4beaf331037649b10625736b41365defb4f50/LICENSE) |
| oaknut | `94c726ce0338b054eb8cb5ea91de8fe6c19f4392` (Dynarmic submodule) | [MIT](https://github.com/merryhime/oaknut/blob/94c726ce0338b054eb8cb5ea91de8fe6c19f4392/LICENSE) |
| robin-map | `054ec5ad67440fcd65e0497e5a27ef31f53fcc7f` (Dynarmic submodule) | [MIT](https://github.com/Tessil/robin-map/blob/054ec5ad67440fcd65e0497e5a27ef31f53fcc7f/LICENSE) |

Individual dependency files may carry additional notices; those notices remain
in place. Local changes do not remove upstream attribution.

The Banner Saga, its artwork, scripts, assets, original native libraries, and
the Adobe AIR and FMOD runtimes are third-party material. They are not supplied
by this repository and are not relicensed under the GPL. You must supply your
own original game files. The patch recipe requires those files and is not a
standalone copy of the game. This project grants no rights to redistribute
proprietary game data or runtimes.

This is an independent, unofficial project, unaffiliated with Stoic, its
publishers, Adobe, or FMOD. Their names and trademarks belong to their respective
owners.
