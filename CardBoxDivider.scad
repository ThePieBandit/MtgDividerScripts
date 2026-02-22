/* 
 * Instructions:
 * 1. Download and install the fonts from here: https://andrewgioia.github.io/Keyrune/index.html & https://andrewgioia.github.io/Mana/index.html
 * 2. Set your front set symbol and your back set symbol by copying the icon from this page: https://andrewgioia.github.io/Keyrune/cheatsheet.html or this page: https://andrewgioia.github.io/Mana/cheatsheet.html. You want the icon, nothing else. If it doesn't look quite right in the string input, that should be ok; the rendering uses the specifc Keyrune font. (if you want, you can use the unicode like \ue93f, but if you don't understand how to do that, just copy and paste the symbol). If you want the same symbol on front and back...paste the same symbol.  If you don't want a symbol on one side, just use an empty string.
 * 3. Set clip_location to false to put the clip on the left side instead. I recommend alternating them.
 */

/* [Divider] */
// Width of the divider. The depth is added to this number.
width = 66;
// Height of the divider. The depth is added to this number.
height = 93;
// Thickness of the divider. Also acts as the diameter of all the rounded edges.
depth = 1.6; // [1.5:0.1:6]
// The number of bars supporting the divider structure. Fairly hollow by default to save material. Setting to about 40 or higher will create a solid divider.
bars = 3; // [0:40]
// Create some feet to help hold the divider in place without supports
addFeet = true;

/* [Clip] */
// if true, adds a clip. If false, there's no clip! No clip is useful if you want to use it in a deckbox or bundle box or something similar.
addClip = true;
// Width of the clip on the side of the divider. This should be slightly bigger than whatever wall you want to clip it to.
clip_width = 10.75;
// Height of the clip on the side of the divider. Higher will make it clip better. Keep it reasonably small though.
clip_height = 15;
// Depth of the clip on the side of the divider. Higher will make it clip better. Keep it reasonably small though.
clip_depth = 3.5;
// Determines which side to place the clip on. Alternating sides every column is recommended. For outer columns, plan on having this face inside. Note that it will always appear on the right in the model for printing purposes, and the text will be reversed, to have the effect of having the clip on the left
clip_location = 1; // [2:Both, 1:Right, 0:Left]
// Number of millimeters to move the clip down the side. Leave at zero for the top of the divider.
clip_vertical_position=0;

/* [Label] */
// Size of how big to make the text. Don't go too big, or it will be blocked by the cards. 
label_size = 10; // [6:24]
// The expansion set symbol for the front of the divider.

// Strongly recommended you use these instead of images.
// The symbol you want on the front side of the divider. Paste this from https://andrewgioia.github.io/Keyrune/cheatsheet.html
front_set = "";
// The symbol you want on the front side of the divider. Paste this from https://andrewgioia.github.io/Mana/cheatsheet.html
front_symbol = "";

// The symbol you want on the back side of the divider. Paste this from https://andrewgioia.github.io/Keyrune/cheatsheet.html
back_set = "";
// The symbol you want on the back side of the divider. Paste this from https://andrewgioia.github.io/Mana/cheatsheet.html
back_symbol = "";

// Variables that make life easier
rad = depth / 2;
rad_w_padding = depth * 3 / 4;
space_size = width / (bars + 1) - depth - 2 * depth / (bars + 1);
font_size = label_size*.9;
footSize = 9;


rotate([0, 0, 90]) {
    difference() {
        translate([-width / 2, -height / 2, 0])rotate([-90, 0, 0])divider();
        addSymbols(front_set, front_symbol);
        rotate([180, 0, 180])addSymbols(back_set, back_symbol);
    }
    if(addClip){
        if(clip_location > 0){
            translate([width / 2, -height / 2, 0])mirror([1, 0, 0])rotate([-90, 0, 0])translate([0, 0, clip_vertical_position])clip();
        } 
        if (clip_location != 1){
            translate([-width / 2, -height / 2, 0])rotate([-90, 0, 0])translate([0, 0, clip_vertical_position])clip();
        }
    }
}
if ( addFeet ) {
    if(!addClip){
        attachFoot(1,1);
        attachFoot(1,-1);
    } else { 
        if(clip_location < 1){
            attachFoot(1,-1);
        } 
        if(clip_location == 1) {
            attachFoot(1,1);
        }
    }
    attachFoot(-1,1);
    attachFoot(-1,-1);
}

module addSymbols(set, symbol) {
    rotate([0, 0, 180]) {
        translate([0, height / 2 - 0.3 * label_size, -rad+0.3]) {
            translate([-width / 3, -label_size / 2, 0]) {
                //print_image(front_set_image);
                linear_extrude(height=depth) {
                    text(set, font="Keyrune", size=font_size, valign="center", halign="center");
                }
            }
            translate([-width / 3 + label_size + label_size / 2 - 1, -label_size / 2, 0]) {
                //print_image( front_symbol_image );
                linear_extrude(height=depth) {
                    text(symbol , font="Mana", size=font_size, valign="center", halign="center");
                }
            }
        }
    }
}

/* Making the divider itself */
module divider() {
    // Make Base Divider
    union(){
        difference() {
            // Start with a rectangle, width x height
            hull() {
                /*  using a flat base instead of rounded corners improves bed adhesion
                corner([0, 0, 0]);
                corner([0, 0, height]);
                corner([width, 0, 0]);
                corner([width, 0, height]);
                */
                translate([-rad, -rad, -rad])cube([width + depth, depth, height + depth]);
            }
            // Add gaps in the main divider to save plastic.
            for(gap=[0:bars]){
                translate([depth + rad + gap * (depth + space_size), -rad, rad_w_padding + 1.5 * label_size]){
                    cube([space_size, depth*2, height - 2 * depth - 1.5 * label_size]);
                }
            }
        }
        // Add 2 cross beams to support the gaps.
        hull(){        
            translate([rad, 0, height - rad])cube([rad, depth, depth], center=true);
            translate([width - rad, 0, rad + 1.5 * label_size])cube([rad, depth, depth], center=true);
        }
        hull(){        
            translate([width - rad, 0, height - rad])cube([rad, depth, depth], center=true);
            translate([rad, 0, rad + 1.5 * label_size])cube([rad, depth, depth], center=true);
        }
    }
}

/* make the clip to attach to the side of the divider */
module clip() {
    // Make Clip Base
    difference(){
        union(){
            hull() {
                corner([width, 0, 0]);
                corner([width, -clip_depth, 0]);
                corner([width + clip_width, 0, 0]);
                corner([width + clip_width, -clip_depth, 0]);
            }
            // Make Clip Side 1
            hull() {
                corner([width, 0, 0]);
                corner([width, -clip_depth, 0]);
                corner([width, -clip_depth, clip_height]);
                corner([width, 0, clip_height * 1.75]);
            }

            // Make Clip Side 2. Make a flat edge with a slightly indented inner edge
            hull() {
                corner([width + clip_width - 0.15, 0, 0]);
                corner([width + clip_width - 0.15, -clip_depth, 0]);
                corner([width + clip_width, 0, 0]);
                corner([width + clip_width, -clip_depth, 0]);
                corner([width + (clip_width * 0.875), 0, clip_height]);
                corner([width + (clip_width * 0.875), -clip_depth * 0.85, clip_height]);
                corner([width + (clip_width), 0 * 0.85, clip_height]);
                corner([width + (clip_width), -clip_depth * 0.85, clip_height]);
            }
        }
        translate([width + clip_width * 2, -clip_depth / 2, clip_height / 2]) {
            rotate([-90,0,90]){
                //print_image(front_set_image);
                linear_extrude(height=clip_width - 0.5) {
                    text(front_set, font="Keyrune", size=clip_depth * 0.75, valign="center", halign="center");
                }
            }
        }
    }
}

/* 
 * Helper to make corners for the rounded edges. Give location as a vector and it will create a sphere with a size of half the depth (the radius). Use hull() to connect them into a shape.
 */
module corner(location) {
    translate(location) {
        union(){
            sphere(rad, $fn=24);
        }
    }
}

/* No longer supported, but it's here if I need it */
module print_image(filename) {
    if (filename != "") {
        scale([0.1, 0.1, rad]) {
            surface(file=filename, center=true, convexity=5);
        }
    }
}

module attachFoot(xMod, yMod) {
    translate([xMod * (height / 2 + 0.0 + rad) - footSize / 2, yMod * (width / 2 + 0.0 + rad) - footSize / 2, -rad])difference(){
        cube([footSize, footSize, rad]);
        translate([-xMod * (footSize / 2 - 0.25), -yMod * (footSize / 2 - 0.25), 0])cube([footSize, footSize, rad]);
    }
    translate([xMod * height / 2 - 0.25 + xMod * rad, yMod * width / 2 - 0.25 + yMod * rad, -rad])footAttachment();
    translate([xMod * height / 2 - 0.25 + xMod * rad - xMod * footSize / 2, yMod * width / 2 - 0.25 + yMod * rad, -rad])footAttachment();
    translate([xMod * height / 2 - 0.25 + xMod * rad, yMod * width / 2 - 0.25 + yMod * rad - yMod * footSize / 2, -rad])footAttachment();
}

module footAttachment() {
    cube([0.5, 0.5, 0.3]);
}
