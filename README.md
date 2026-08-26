# BossTTD

A World of Warcraft addon for **TBC Anniversary Edition** written in TypeScript and transpiled to Lua using TypeScript-To-Lua (TTL). 

The timer displays automatically **only during active boss encounters**.

---

## Repository Layout

* **Root (`/`)**: Contains entry points, main configuration files, and ready-to-use Lua outputs.
* **`src/`**: TypeScript source code.
* **`target/`**: Target build directory containing the compiled Lua addon structure.
* **`build.ps1`**: PowerShell build script.

---

## Build & Installation

1. **Build the Project**
   Execute the build script in your terminal/IDE:
   
   .\build.ps1

2. **Deploy to AddOns Directory**
   Copy the compiled folder inside `target/` into your TBC Anniversary AddOns folder:
   
   World of Warcraft\_anniversary_\Interface\AddOns\

3. **Verify in-Game**
   Launch World of Warcraft (or run `/reload` in-game). The timer will trigger automatically upon engaging a boss.

---

## Behavior

* **Passive Operation:** Zero manual configuration required.
* **Conditional Visibility:** UI renders strictly when a boss encounter begins and hides automatically upon combat completion.
