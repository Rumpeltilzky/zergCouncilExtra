### 0.8.1
---
* Pawn scores are now again calculated even if other's doesn't have EU installed.


##### Bugfixes
* *Fixed a bug introduced in the last update.*


### 0.8.0
---
* Updated for Battle for Azeroth.
* Removed Legendaries, Upgrades, and Ilvl Upgrade columns as those are no longer in the game.
* Updated Artifact Traits column to show Heart of Azeroth level.
* Updated Forged column to reflect BfA Warforged/Titanforged items.


### 0.7.0 (patch 8.0)
---
* Updated .toc for patch 8.0.

### 0.6.2
---
* Utilizes specID's sent from RCLootCouncil to more consistently show spec icons.
* Updated to use new chat command format in RCLootCouncil v2.7.6.


### v0.6.1
---
* Prepared for RCLootCouncil v2.7 changes.


### v0.6.0
---
* **EPGP**
* EPGP support has been removed. Use [RCLootCouncil - EPGP](https://mods.curse.com/addons/wow/269161-rclootcouncil-epgp) for that.

* You can now save all bonus rolls to the loot history.
* All textures/buttons now updates on the fly when changing column positions.

### v0.5.2
---
* Updated .toc for 7.3.


### v0.5.1
---
* Updated for future RCLootCouncil changes.

##### Bugfixes
+ *Fixed error related to bonus rolls (#3).*

### v0.5.0
---
* **Spec**
  * Specs can now be gathered from inspects, meaning all spec related stuff doesn't require other people to have ExtraUtilities installed.
  * This affects the spec icon and Pawn calculations.

* **EPGP**
  * Added new columns for EP, GP and PR. Courtesy of safetee.
  * Note: these columns will only display data as it's stored from EPGP.

* All ExtraUtilities columns now have "response" as their secondary sort.

##### Bugfixes
+ *Bonusrolls before a session was started would not get displayed.*
+ *Added check for external requirements.*

### v0.4.1
---
##### Bugfixes
+ *Fixed a bug related to bonus rolls.*

### v0.4.0
---
* **Column Width**
 * You're now able to change the width of all columns.
 * Located in a separate options tab to keep it organized.


* **Column Position**
 * You can now change the positions of all columns.


* **Pawn**
 * Candidates now, by default, send out their own Pawn scores so councilmen doesn't have to calculate them.
 * Added percentage upgrade display, which is now used by default.
 * Both of these additions are changeable in the options menu ("/rc eu").


* **Other**
 * Now updates the voting frame immediately when data is received.

### v0.3.0
---
* **Bonus Roll**
 * Added a new column showing the candidates' bonus roll, if any.


* **Guild Notes**
 * Added a new column showing a candidates guild notes, if accessible.


### v0.2.0
---
* **Sorting**
 * The new columns can now be sorted.


* **Pawn**
 * Pawn scores are now enabled.
 * Have a look at the Pawn section in the options menu to customize which scales are being used.


* **Spec Icon**
 * Added a new column showing the candidates' specialization.