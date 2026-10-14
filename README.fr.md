<!-- i18n-source: README.md@94b97a975e1661e3e71258990ab1da5129f7bc04 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/banner-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/banner-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/banner-fr-light.svg" alt="Animation Masterclass: Mouvements physiques, particules, effets de changement et transitions pour SwiftUI sur iOS et macOS."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/actions/workflows/ci.yml/badge.svg" alt="État de la CI"></a>
<a href="https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-version-light.svg" alt="Dernière version: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-platforms-light.svg" alt="Plateformes prises en charge: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-language-light.svg" alt="Version du langage: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-license-light.svg" alt="Licence: MIT"></picture></a>
</p>

<p align="center">
<a href="#démarrage-rapide"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-start-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-start-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-start-fr-light.svg" alt="Commencer"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftUI-Animation-Masterclass/documentation/swiftuianimationmasterclass/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-docs-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-docs-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-docs-fr-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-examples-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-examples-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-examples-fr-light.svg" alt="Exemples"></picture></a>
</p>

> Ceci est une traduction du README anglais. En cas de différence, la version anglaise fait foi.

<!-- brand:end -->

Un package Swift de mouvement pour SwiftUI sur iOS 17+ et macOS 14+ : ressorts physiques, decay (amortissement) et rebonds, glissements qui conservent la vitesse du doigt, effets de particules, effets de changement et transitions. Il s’adresse aux développeurs d’apps qui veulent un effet sur un écran sans adopter tout un framework : tout est un view modifier, une `Animation`, une `Transition` ou un simple type valeur, et le package n’a aucune dépendance.

## Points forts

- **Une physique que vous appelez directement** — `DampedSpring` résout l’équation du ressort sous forme fermée (les tests la comparent à une intégration numérique), `Decay` prévoit où s’arrête un geste de lancer, `GravityBounce` fait tomber une valeur et la fait rebondir, et `.gravityBounce()` l’exécute comme une animation SwiftUI.
- **Des glissements qui gardent leur élan** — `.elasticDrag()` et `.snapDrag(_:offsets:selection:)` transmettent au ressort la vitesse au relâchement, s’étirent avec une résistance élastique au-delà des extrémités et laissent un lancer se poursuivre jusqu’à la position de repos suivante.
- **Des particules dans un seul Canvas** — 8 préréglages, 5 forces et 7 formes (dont des SF Symbols et des emoji) dessinés par un seul `Canvas`, avec une simulation à graine qui produit les mêmes images pour la même graine et ne garde jamais plus de 10 000 particules.
- **Effets de changement et transitions** — shake, jump, spin, pulse, ping et shine joués lorsqu’une valeur change, et transitions iris, wipe, flip et pop reposant sur le protocole `Transition` d’iOS 17.
- **Prise en charge du réglage « Réduire les animations »** — lorsque ce réglage est activé, les particules ne sont pas dessinées, les effets de changement ne sont pas joués, les transitions se fondent et les glissements s’arrêtent avec un court ease-out.
- **Testé, Swift 6** — 70 tests Swift Testing sur macOS, dont 66 également sur un simulateur d’iPhone, y compris avec des entrées NaN, infinies et hors plage ; le package se compile en mode de langage Swift 6.

### Contenu

| Domaine | API |
| --- | --- |
| Physique | `DampedSpring` (`gentle`, `snappy`, `bouncy`, `smooth`), `Decay`, `GravityBounce`, `.gravityBounce(fallDuration:restitution:)`, `RubberBand`, `SnapPoints` |
| Gestes | `.elasticDrag(axes:resistance:spring:)`, `.snapDrag(_:offsets:selection:decay:spring:)` |
| Particules | `.particleBurst(_:trigger:)`, `.particleEffect(_:isActive:)`, `ParticleView`, `ParticleEmitter`, `ParticleForce`, `ParticleSystem` |
| Préréglages | `confetti`, `fireworks`, `snow`, `rain`, `sparkles`, `bubbles`, `hearts`, `embers` |
| Effets de changement | `.changeEffect(_:value:)` avec `.shake`, `.jump`, `.spin`, `.pulse`, `.ping`, `.shine` |
| Transitions | `.iris(origin:)`, `.wipe(from:)`, `.flip(axis:)`, `.pop` |
| Défilement | `.scrollDriven(multiplier:)` (parallaxe) |
| Démo | `AnimationShowcase`, un écran avec un effet de chaque type |

## Démarrage rapide

**1. Ajouter le paquet**

Dans Xcode, choisissez **File › Add Package Dependencies…** et saisissez l’URL du dépôt :

```text
https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git
```

Collez-la dans le champ de recherche en haut à droite de la fenêtre. Laissez **Dependency Rule** sur **Up to Next Major Version** à partir de `2.0.0`, puis cliquez sur **Add Package**. Dans la fenêtre suivante, choisissez la cible de votre app à côté de **SwiftUIAnimationMasterclass** et cliquez de nouveau sur **Add Package**.

**2. Importer le module**

```swift
import SwiftUIAnimationMasterclass
```

**3. L’utiliser**

Ajoutez un modifier à n’importe quelle vue. Ce bouton « J’aime » saute et lance une gerbe de cœurs à chaque appui :

```swift
import SwiftUI
import SwiftUIAnimationMasterclass

struct LikeButton: View {
    @State private var likes = 0

    var body: some View {
        Button("Like", systemImage: "heart.fill") { likes += 1 }
            .buttonStyle(.borderedProminent)
            .changeEffect(.jump(), value: likes)
            .particleBurst(.hearts, trigger: likes)
    }
}
```

Pour voir tous les effets avant d’écrire du code, placez `AnimationShowcase()` dans un `#Preview`.

## Installation

### Swift Package Manager

Dans Xcode, choisissez **File › Add Package Dependencies…** et saisissez l’URL du dépôt :

```text
https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git
```

Ou ajoutez-le aux `dependencies` de votre `Package.swift` :

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "SwiftUIAnimationMasterclass", package: "SwiftUI-Animation-Masterclass")
    ])
]
```

Utilisez la version 2.0.0 ou une version ultérieure : la version 1.0.0 ne se compilait pas.

## Utilisation

Chaque exemple ci-dessous est copié depuis [`ReadmeSamples.swift`](Examples/MotionGallery/MotionGallery/ReadmeSamples.swift), que l’app d’exemple et la cible de tests compilent.

### Faire tomber une valeur avec un rebond

`.gravityBounce()` est une `Animation` : la valeur tombe sur sa nouvelle cible et y rebondit.

```swift
struct DropBadge: View {
    @State private var isDropped = false

    var body: some View {
        Image(systemName: "bell.fill")
            .font(.largeTitle)
            .offset(y: isDropped ? 0 : -120)
            .animation(.gravityBounce(restitution: 0.5), value: isDropped)
            .onAppear { isDropped = true }
    }
}
```

### Fêter avec des particules

`.particleBurst(_:trigger:)` émet une gerbe à chaque changement de valeur ; `.particleEffect(_:)` maintient un effet actif sur une vue.

```swift
struct OrderButton: View {
    @State private var orders = 0

    var body: some View {
        Button("Place order") { orders += 1 }
            .buttonStyle(.borderedProminent)
            .particleBurst(.confetti, trigger: orders)
    }
}

struct WinterScene: View {
    var body: some View {
        LinearGradient(colors: [.indigo, .blue], startPoint: .top, endPoint: .bottom)
            .particleEffect(.snow)
            .ignoresSafeArea()
    }
}
```

### Attirer l’attention sur un changement

```swift
struct PasswordField: View {
    @State private var password = ""
    @State private var failures = 0

    var body: some View {
        SecureField("Password", text: $password)
            .textFieldStyle(.roundedBorder)
            .changeEffect(.shake(), value: failures)
            .onSubmit { if password.count < 8 { failures += 1 } }
    }
}
```

### Afficher et masquer des vues

Les transitions fonctionnent avec `if` et `withAnimation` comme les transitions intégrées.

```swift
struct PhotoReveal: View {
    @State private var showsPhoto = false

    var body: some View {
        VStack {
            Button(showsPhoto ? "Hide" : "Reveal") {
                withAnimation(.smooth(duration: 0.6)) { showsPhoto.toggle() }
            }
            if showsPhoto {
                Image(systemName: "photo.artframe")
                    .font(.system(size: 120))
                    .foregroundStyle(.blue)
                    .transition(.iris(origin: .topTrailing))
            }
        }
        .frame(height: 220, alignment: .top)
    }
}
```

### Glisser avec de l’élan

Un panneau qui se tire vers le haut, avec deux positions d’arrêt (detents) : un relâchement lent revient à la plus proche, un lancer passe à la suivante.

```swift
struct PullUpPanel: View {
    @State private var detent = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.blue.gradient)
            .frame(height: 400)
            .overlay(alignment: .top) {
                Capsule().fill(.white.opacity(0.6)).frame(width: 40, height: 5).padding(10)
            }
            .snapDrag(.vertical, offsets: [0, 260], selection: $detent)
    }
}
```

### Concevoir votre propre effet de particules

Chaque paramètre de l’émetteur a une valeur par défaut ; ne réglez donc que ce qui rend l’effet différent :

```swift
let stardust = ParticleEmitter(
    source: .edge(.bottom),
    birthRate: 30,
    lifetime: 2...3,
    speed: 60...120,
    direction: .degrees(-90),
    spread: .degrees(20),
    size: 6...10,
    endScale: 0.3,
    forces: [.vortex(center: .center, strength: 80), .gravity(-20)],
    colors: [.white, .cyan],
    shapes: [.star],
    fadeIn: 0.1,
    blending: .additive
)
```

## Démo

Rendu image par image à partir du code de simulation et d’effets du package lui-même par [`scripts/render-readme-media.sh`](scripts/render-readme-media.sh) (couleurs des particules réglées sur la palette bleue, comme dans la section Utilisation) :

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/particles-dark.gif">
  <img src="docs/images/particles-light.gif" alt="Gerbes de confettis et de feux d’artifice, neige et braises dessinées par ParticleSystem" width="720">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/effects-dark.gif">
  <img src="docs/images/effects-light.gif" alt="Les effets de changement shake, jump, spin, pulse, ping et shine" width="720">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/physics-dark.gif">
  <img src="docs/images/physics-light.gif" alt="Une balle lâchée avec gravityBounce, un DampedSpring rebondissant et un lancer Decay" width="720">
</picture>

Écrans de l’app d’exemple sur un simulateur d’iPhone, capturés par [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) :

| Laboratoire de physique | Effets de changement | Transitions |
| --- | --- | --- |
| ![Laboratoire de physique, clair](docs/images/example-physics-light.png) | ![Effets de changement, clair](docs/images/example-effects-light.png) | ![Transitions, clair](docs/images/example-transitions-light.png) |
| ![Laboratoire de physique, sombre](docs/images/example-physics-dark.png) | ![Effets de changement, sombre](docs/images/example-effects-dark.png) | ![Transitions, sombre](docs/images/example-transitions-dark.png) |

Pour essayer les effets vous-même, ouvrez `MotionGallery.xcodeproj` dans [`Examples/MotionGallery`](Examples/MotionGallery) avec Xcode, choisissez un simulateur d’iPhone ou **My Mac**, puis appuyez sur **Run**. [Examples/README.md](Examples/README.md) donne les détails.

## Documentation

Référence de l’API et articles :

- [Référence de l’API](https://muhittincamdali.github.io/SwiftUI-Animation-Masterclass/documentation/swiftuianimationmasterclass/)
  (DocC, publiée sur GitHub Pages depuis `main`)
- Générez-la en local dans Xcode avec **Product › Build Documentation**, ou en ligne de commande :

```sh
xcodebuild docbuild -scheme SwiftUIAnimationMasterclass -destination 'generic/platform=macOS'
```

## Guides

- [Getting Started](https://muhittincamdali.github.io/SwiftUI-Animation-Masterclass/documentation/swiftuianimationmasterclass/gettingstarted)
  — ajouter le package, puis un rebond, une gerbe, une secousse et une transition
  ([source](Sources/SwiftUIAnimationMasterclass/SwiftUIAnimationMasterclass.docc/GettingStarted.md)).
- [Throwing and Snapping](https://muhittincamdali.github.io/SwiftUI-Animation-Masterclass/documentation/swiftuianimationmasterclass/throwingandsnapping)
  — les modifiers de glissement, ainsi que les ressorts, le decay et les points d’accroche qui les sous-tendent
  ([source](Sources/SwiftUIAnimationMasterclass/SwiftUIAnimationMasterclass.docc/ThrowingAndSnapping.md)).
- [Designing Particle Effects](https://muhittincamdali.github.io/SwiftUI-Animation-Masterclass/documentation/swiftuianimationmasterclass/designingparticleeffects)
  — préréglages, émetteurs, forces, limites et pilotage de la simulation par vous-même
  ([source](Sources/SwiftUIAnimationMasterclass/SwiftUIAnimationMasterclass.docc/DesigningParticleEffects.md)).
- [Respecting Reduce Motion](https://muhittincamdali.github.io/SwiftUI-Animation-Masterclass/documentation/swiftuianimationmasterclass/respectingreducemotion)
  — ce que fait chaque effet lorsque le réglage est activé
  ([source](Sources/SwiftUIAnimationMasterclass/SwiftUIAnimationMasterclass.docc/RespectingReduceMotion.md)).

## Prérequis

| Plateforme | Version minimale |
| --- | --- |
| iOS | 17 |
| macOS | 14 |
| Chaîne d’outils | Swift 6.2 · Xcode 26+ |

## Architecture

- `Sources/SwiftUIAnimationMasterclass/` contient un dossier par domaine : `Physics`, `Gestures`, `Particles`, `Effects`, `Transitions`, `Scroll` et `Showcase`.
- Le mouvement est calculé par des types valeur sans code de vue : `DampedSpring`, `Decay`, `GravityBounce`, `RubberBand`, `SnapPoints`, `ParticleSystem` et `ChangeEffect.state(at:)`. Les modifiers se contentent de lire l’environnement, de conserver l’état du geste ou de l’animation et d’appliquer le résultat ; les calculs sont donc testés unitairement sans écran.
- `ParticleSystem` est un struct doté d’un générateur SplitMix64 : une graine détermine entièrement les particules sur toutes les plateformes. `ParticleView` le fait avancer dans une `TimelineView` et dessine toutes les particules dans un seul `Canvas` ; l’horloge se met en pause quand plus rien n’est vivant.
- Les valeurs venant de l’extérieur du package (réglages d’émetteur modifiés à l’exécution, durées d’image, tailles de canvas, vitesses de geste) sont bornées : les nombres non finis n’atteignent pas la simulation, et le nombre de particules et de rebonds a des limites strictes.
- CI exécute `swift test` sur macOS et `xcodebuild test` sur un simulateur d’iPhone, compile l’app d’exemple pour iOS et macOS, et publie la documentation DocC.

Pour lancer les tests en local :

```sh
swift test                                    # macOS
xcodebuild test -scheme SwiftUIAnimationMasterclass \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Feuille de route

- Ajouter le package au Swift Package Index ; `.spi.yml` est déjà dans le dépôt.
- Une animation suivant un tracé (déplacer une vue le long d’un `Path` avec une courbe de timing).
- Davantage de transitions fondées sur le même protocole `Transition`, comme un effet de page qui se tourne.

## Contribuer

Les contributions sont les bienvenues. Lisez le [guide de contribution](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/CONTRIBUTING.md) et le [code de conduite](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) avant d’ouvrir une pull request. Signalez les problèmes de sécurité en privé, comme indiqué dans la [politique de sécurité](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).

## Licence

Publié sous licence MIT. Voir [LICENSE](LICENSE).
