// TV speaker sound channel, v0.1 fit-test design.
//
// A clip/screw-on scoop for one bottom-firing TV speaker. It captures the
// sound at the underside grille and turns it 90 degrees so it exits toward
// the front of the TV.
//
// Print one normal and one mirrored channel:
//   side =  1  -> screw tab toward +X
//   side = -1  -> screw tab toward -X
//
// Coordinate system, in millimetres:
//   origin       centre of the speaker grille
//   z = 0        TV underside; the part extends downward to negative z
//   +y           toward the front face of the TV
//   x            along the width of the TV / long axis of the grille
//
// Measurements supplied by Jordan on 2026-11-16:
//   grille                    3.50 x 1.75 in (88.9 x 44.5 mm), flush underneath
//   TV front to grille front  1.00 in (25.4 mm)
//   screw-hole spacing        0.75 in (19.05 mm)
//   grille side to hole pair  1.50 in (38.1 mm)
//   TV side edge to grille    3.00 in (76.2 mm)
//   screw diameter            1/8 in (3.175 mm)
//
// Assumptions for this first fit test:
//   * The hole pair is on the outboard side of the grille.
//   * The 1.50 in dimension is to the centre of the hole pair. This also puts
//     the pair halfway between the TV edge and the grille (both gaps are 3 in
//     in total: 1.5 in from the edge to the pair and 1.5 in to the grille).
//   * hole_axis defaults to "front_back". Change it to "left_right" if the
//     two holes are spaced along the width of the TV instead.

side = 1;                    // [1, -1]
hole_axis = "front_back";    // ["front_back", "left_right"]

$fn = 48;

// ---------------------------------------------------------------------------
// Measured dimensions
// ---------------------------------------------------------------------------

grille_w = 88.9;             // 3.50 in, left-to-right
grille_d = 44.5;             // 1.75 in, front-to-back
front_to_grille = 25.4;      // front face to front edge of grille
hole_spacing = 19.05;        // 0.75 in, centre-to-centre
hole_pair_from_grille = 38.1;// 1.50 in, grille edge to pair centre
screw_d = 3.175;             // 1/8 in nominal screw

// ---------------------------------------------------------------------------
// Design dimensions
// ---------------------------------------------------------------------------

wall = 2.5;                  // duct side walls
back_wall = 6.0;             // material behind the air path
floor_t = 3.0;               // material below the air path
flange_t = 4.0;              // mounting plate thickness
flange_side_margin = 10.5;   // flange extension beside the grille
flange_back_margin = 6.0;    // flange extension behind the grille
hole_clearance_d = 3.6;      // printed clearance hole for the 1/8 in screw
tab_width = 32.0;            // front-to-back width of the screw tab
tab_end_margin = 15.45;      // tab material beyond the hole-pair centre

bend_leg = 8.0;              // straight drop before the bend starts
bend_radius = 26.0;          // centreline radius of the 90-degree turn

eps = 0.1;

// Derived dimensions
front_face_y = grille_d / 2 + front_to_grille;
flange_x = grille_w / 2 + flange_side_margin;
flange_back_y = -(grille_d / 2 + flange_back_margin);
body_back_y = -(grille_d / 2 + back_wall);
body_half_x = grille_w / 2 + wall;
hole_pair_x = side * (grille_w / 2 + hole_pair_from_grille);
tab_outer_x = abs(hole_pair_x) + tab_end_margin;
duct_drop = bend_leg + bend_radius + grille_d / 2 + floor_t;

// ---------------------------------------------------------------------------
// Air path
// ---------------------------------------------------------------------------

// The profile is drawn in 2D as (d, y), where d is distance below the TV
// underside and y is distance toward the front of the TV.
module air_path_profile() {
  union() {
    // Straight vertical portion. It starts slightly above z=0 in the final
    // part so the subtraction cuts cleanly through the mounting flange.
    translate([(bend_leg - 1) / 2, 0])
      square([bend_leg + 1, grille_d], center = true);

    // Round end of the vertical portion.
    translate([bend_leg, 0])
      circle(r = grille_d / 2);

    // Quarter-annulus bend.
    translate([bend_leg, bend_radius])
      intersection() {
        difference() {
          circle(r = bend_radius + grille_d / 2);
          circle(r = bend_radius - grille_d / 2);
        }
        // Keep the quadrant that turns downward flow toward +y.
        translate([0, -(bend_radius + grille_d / 2)])
          square([bend_radius + grille_d / 2,
                  bend_radius + grille_d / 2]);
      }

    // Straight horizontal portion, ending just beyond the TV front face.
    translate([bend_leg + bend_radius,
               (bend_radius + front_face_y + 1) / 2])
      square([grille_d, front_face_y + 1 - bend_radius], center = true);

    // Round joint at the start of the horizontal portion.
    translate([bend_leg + bend_radius, bend_radius])
      circle(r = grille_d / 2);
  }
}

// Extrude the profile across the grille width, then rotate it into the
// part coordinate system: profile d becomes -z and extrusion becomes x.
module air_path() {
  rotate([0, 90, 0])
    linear_extrude(height = grille_w, center = true)
      air_path_profile();
}

// ---------------------------------------------------------------------------
// Mounting flange
// ---------------------------------------------------------------------------

module flange_profile() {
  union() {
    // Main plate. Its front edge is flush with the front face of the TV.
    translate([0, (flange_back_y + front_face_y) / 2])
      square([2 * flange_x, front_face_y - flange_back_y], center = true);

    // Outboard tab. It starts 5 mm inside the main plate so the exported
    // part is a single fused solid rather than two pieces touching at a face.
    translate([side * ((flange_x - 5) + tab_outer_x) / 2, 0])
      square([tab_outer_x - flange_x + 5, tab_width], center = true);
  }
}

module flange() {
  translate([0, 0, -flange_t])
    linear_extrude(height = flange_t)
      flange_profile();
}

// ---------------------------------------------------------------------------
// Complete channel
// ---------------------------------------------------------------------------

module speaker_channel() {
  difference() {
    union() {
      flange();

      // Duct body. The top is coplanar with the TV underside and overlaps
      // the flange through its full thickness.
      translate([0, (body_back_y + front_face_y) / 2, -duct_drop / 2])
        cube([2 * body_half_x,
              front_face_y - body_back_y,
              duct_drop], center = true);
    }

    // Hollow 90-degree air path and grille opening.
    air_path();

    // Screw holes. Their positions are controlled by hole_axis.
    hole_positions =
      hole_axis == "left_right"
        ? [[hole_pair_x - hole_spacing / 2, 0],
           [hole_pair_x + hole_spacing / 2, 0]]
        : [[hole_pair_x, -hole_spacing / 2],
           [hole_pair_x,  hole_spacing / 2]];

    for (p = hole_positions)
      translate([p[0], p[1], -flange_t - eps])
        cylinder(h = flange_t + 2 * eps, d = hole_clearance_d, $fn = 32);
  }
}

speaker_channel();
