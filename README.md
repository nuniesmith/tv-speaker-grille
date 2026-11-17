# TV speaker sound channels

Parametric OpenSCAD scoops for the bottom-firing speakers in Jordan's Amazon
Fire TV. Each channel seals over one underside speaker grille, turns the
sound 90 degrees, and sends it out toward the front of the TV.

The channels are a mirrored pair. Each one mounts with the two existing
screw holes beside its speaker grille.

## Model

Source: [`tv_speaker_channel.scad`](tv_speaker_channel.scad)

Exports:

- `stl/tv_speaker_channel_side_1.stl`
- `stl/tv_speaker_channel_side_-1.stl`

To make the other side, set `side = -1` near the top of the SCAD file. The
`side` value controls which way the screw tab points.

## Dimensions used for v0.1

All dimensions were measured on the TV on 2026-11-16.

| Feature | Measurement |
| --- | ---: |
| Speaker grille | 3.50 x 1.75 in (88.9 x 44.5 mm) |
| Grille surface | Flush with TV underside |
| TV front face to grille front edge | 1.00 in (25.4 mm) |
| Screw-hole spacing | 0.75 in (19.05 mm) |
| Grille side edge to hole-pair centre | 1.50 in (38.1 mm) |
| TV side edge to grille side edge | 3.00 in (76.2 mm) |
| Nominal screw diameter | 1/8 in (3.175 mm) |

The printed screw holes are 3.6 mm to clear a nominal 1/8 in screw.

### Fit-test assumptions

These points still need confirmation against the first print:

1. The screw holes are outboard of the grille, between the grille and the
   nearest edge of the TV.
2. The 1.50 in measurement is to the centre of the two-hole pair.
3. The holes are spaced front-to-back. If they are spaced left-to-right,
   change `hole_axis` in the SCAD file from `"front_back"` to
   `"left_right"` and re-export.

The underside of the finished channel extends about 59 mm (2.33 in) below
the TV. The outlet is flush with the front face of the TV.

## Printing and fitting

This is a v0.1 fit-test part, not the final acoustic/mechanical revision.

Suggested first print:

- Print one side only and test the grille alignment and screw holes before
  printing its mirror.
- Use the flange/top face as the reference face in the slicer.
- Supports may be needed inside the curved duct, depending on orientation.
- Check that the flange sits flat and that neither screw is forced sideways.
- Do not overtighten the screws; the TV's threaded inserts and their useful
  thread depth have not been measured.

Possible v0.2 changes after the fit test include a foam-gasket groove,
reinforcing ribs for the screw tab, a smoother/larger bend, and a grille or
taper at the outlet.
