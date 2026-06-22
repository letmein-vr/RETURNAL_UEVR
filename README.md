![Returnal VR](https://raw.githubusercontent.com/letmein-vr/RETURNAL_UEVR/main/screenshots/returnalvr.png)

> [!IMPORTANT]
> **UEVR Latest Nightly Required** — Latest nightly here: https://github.com/praydog/UEVR-nightly/releases

---

## Credits
* **Praydog**: For creating [UEVR](https://github.com/praydog/UEVR) and making these mods possible!
* **jbusfield**: For the incredible helper libs framework used as the basis for this project (https://github.com/jbusfield/uevrlib).

---

## Features
* **Full 1st Person 6DOF**: Complete 6DOF motion control support.
* **VR Hands**: VR rendered hands with grip animations for equipped weapons, attached to left and right motion controllers.
* **6DOF Weapons**: Selene's current weapon is tracked and attached to the right controller, with VR hands following accordingly.
* **UI HUD Follow Mode**: Configurable — UI HUD can follow HMD (head) or the right controller. Toggle in the UEVR config panel.
* **Cinematic Handling**: Automatic detection of cinematic camera sequences (`BP_Cinematic`). Object hooks are disabled and VR aim method switches during cutscenes to preserve the original cinematic presentation, then restores on exit.
* **Parasites Hidden**: Parasite actors that attach to Selene are automatically hidden in VR to prevent visual clutter in first person view.

## CONTROLS

![Returnal VR](https://raw.githubusercontent.com/letmein-vr/RETURNAL_UEVR/main/screenshots/IMG_4743.jpeg)

## ⚠️ Known Issues
* **Parasite Visibility**: Parasite hiding relies on actor name matching and may not catch all parasite types depending on level.
* **Cinematic Transitions**: Brief frame where object hooks disable before the cinematic camera fully takes over may cause a visible pop.
* **Graphical Issues**: Some geometry and shadow artefacts in first-person that are inherent to a game not originally built for VR. Cvars should fix shadows along with correct in game settings.
