# Smash A Bread: 3D asset prompts

Paste each prompt into Waspes 3D (or any text-to-3D tool). Each model's name in
Studio must match the **Name** exactly, because `GameConfig.luau` looks models up
by that name under `ReplicatedStorage/Assets/Models`.

## Shared style (already included in every prompt)

Low-poly, chunky cartoon look, bright saturated colors, flat shading with soft
hand-painted texture, no realistic detail, clean silhouette, readable from far away.

## Export checklist (all models)

- One mesh per model, textured, **under about 5,000 triangles** (bosses and the platform can go to about 8,000)
- Pivot at the **bottom center** of the model (weapons: at the grip)
- Face the model toward **-Z** (front)
- Studio import: put it in a `Model` named exactly as below, with the mesh set as `PrimaryPart`
- Size in studs is a target; resize in Studio after import if needed

---

## Bread targets (cartoon bread with a face)

All four: the face is part of the texture (big glossy eyes, small smile), no separate parts.

### WhiteBread (about 4 studs wide)
```
Low-poly cartoon loaf of sliced white sandwich bread, chunky rounded rectangular
shape with a golden-brown domed top crust and soft cream-white sides. Cute
kawaii face on the front: two big glossy black eyes with white highlights, rosy
pink cheeks, small happy smile. Bright saturated colors, flat shading, soft
hand-painted texture, clean silhouette, game-ready, no realistic detail.
Stubby, slightly squished proportions. Single mesh, under 5000 triangles.
```

### GarlicBread (about 5 studs long)
```
Low-poly cartoon garlic bread: a halved baguette-style loaf, golden-toasted
crust, glistening yellow butter on top with green parsley flecks and little
white garlic-clove shapes. Mischievous face on the front: two big shiny eyes,
one eyebrow raised, cheeky smirk. Bright saturated colors, flat shading,
hand-painted texture, chunky clean silhouette, game-ready, under 5000 triangles.
```

### Sourdough (about 7 studs wide)
```
Low-poly cartoon sourdough boule: big round rustic loaf with a dark golden-brown
crackled crust and a decorative diagonal scoring pattern across the top, dusted
with white flour. Tough, grumpy face on the front: heavy brows, narrowed eyes,
frowning mouth. Bright saturated colors, flat shading, hand-painted texture,
chunky simple silhouette, game-ready, under 5000 triangles.
```

### MegalodonLoaf (boss, about 30 studs long)
```
Low-poly cartoon giant boss: a huge loaf of bread shaped like a megalodon shark,
long torpedo body with golden-brown crust, a blue-gray crusty top that fades to
cream-white underside, large triangular dorsal fin and tail fin made of baked
crust, a wide open mouth with rows of big white dough-teeth. Fierce but
cartoonish face: big angry yellow eyes, thick brow ridges. Bright saturated
colors, flat shading, hand-painted texture, strong clean silhouette that reads
from far away, game-ready, under 8000 triangles.
```

---

## Weapons (held in one hand; grip at the pivot)

### WoodenSmasher (about 5 studs long)
```
Low-poly cartoon wooden mallet for smashing, chunky oversized rounded wooden head
with visible wood-grain bands and two darker wooden hoops, short thick wooden
handle with a brown leather wrap at the grip. Simple, friendly, starter-weapon
look. Bright saturated warm browns, flat shading, hand-painted texture, clean
silhouette, game-ready, under 3000 triangles.
```

### GoldenBaguette (about 6 studs long)
```
Low-poly cartoon baguette turned into a weapon: a long golden-brown baguette with
diagonal scoring slashes, but coated in shiny gold with a bright yellow metallic
glow, a small ornate gold hand-guard near the base and a red cloth grip wrap.
Heroic rare-weapon look, sparkle highlights painted into the texture. Bright
saturated colors, flat shading, clean silhouette, game-ready, under 3000
triangles.
```

### DiamondSmasher (about 6 studs long)
```
Low-poly cartoon diamond war hammer: a big chunky hammer head made of faceted
cyan-blue crystal diamond with bright white edge highlights and inner glow,
thick dark-blue handle with silver bands and a glowing blue gem at the pommel.
Epic top-tier weapon look. Bright saturated cyan and blue, flat shaded facets,
hand-painted texture, clean silhouette, game-ready, under 4000 triangles.
```

---

## Environment

### MerchantCart (about 10 studs long)
```
Low-poly cartoon merchant cart: a cozy wooden market wagon with two big round
spoked wheels, a striped red-and-cream canvas awning on top, shelves in front
stacked with loaves, golden coins and little potion bottles, a hanging lantern
and a small "SHOP" sign with a bread icon. Warm, inviting. Bright saturated
colors, flat shading, hand-painted texture, clean silhouette, game-ready, under
6000 triangles.
```

### FloatingEventSpawner (about 40 studs across)
```
Low-poly cartoon floating island platform: a round chunk of earth and stone
floating in the sky, flat grassy top with a glowing purple summoning circle in
the center, a few crystal spikes and stone pillars around the edge, small
rock chunks and roots hanging from the underside. Magical event-arena feel.
Bright saturated colors, flat shading, hand-painted texture, clean silhouette,
game-ready, under 8000 triangles.
```

### LowPolyTree (about 14 studs tall)
```
Low-poly cartoon tree: a short thick brown trunk with a bright green layered
rounded canopy made of 3 chunky blobs, a few lighter highlight patches, tiny
roots at the base. Simple, cheerful, designed to be placed many times. Bright
saturated greens, flat shading, hand-painted texture, clean silhouette,
game-ready, under 1500 triangles.
```
