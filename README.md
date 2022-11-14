# EmulationStation Wrapper Theme

This theme reads existing themes from EmulationStation and wraps them under a RetroHub theme.

This way you can use a bunch of pre-existing themes with minimal effort.

## About support of EmulationStation-DE themes

This wrapper supports themes for:

- [Original EmulationStation](https://emulationstation.org/)
- [RetroPie's fork of EmulationStation](https://github.com/RetroPie/EmulationStation)

On more technical terms, this wrapper support themes with `<formatVersion>` up to version **6**. Themes with version **7** may use some new features from [EmulationStation-DE](https://es-de.org/) and or [Batocera](https://batocera.org/) that this wrapper doesn't support.

This wrapper will **not** support [EmulationStation-DE](https://es-de.org/) themes that run under their new theme engine _(v2.0)_ for two main reasons:

- **ES-DE** is introducing new features very fast. Keeping up with such changes would require a lot of effort. The theme engine rewrite, for instance, is introducing a huge amount of customizability lacking from the original project, that RetroHub may at some point no longer be able to fully support.
- **ES-DE** is an active project, so I don't consider ethical to create a wrapper that would match the original program in functionality. The objective of wrapper themes is for users to have an easier transition into RetroHub, and not to completely replicate another frontend.