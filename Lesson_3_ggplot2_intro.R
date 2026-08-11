################################################################################
# Day 3: Data Visualization with ggplot2
# Cancer Bioinformatics Workshop
################################################################################

# Day 1: base R. Day 2: dplyr, to reshape data into the answer you want.
# Today: how to SHOW it.

# Here's the thing about Day 2. Every result we made was a table of numbers.
# Tables are precise and nobody looks at them. No one has ever glanced at a
# 40-row summarise() output and gone "ah, I see the pattern." A plot they see
# in two seconds.

# We're going to learn ggplot2 on Pokemon data before we touch cancer data.
# That's on purpose. Pokemon has no missing values, no censoring, no units
# problem, and you already know whether the answer looks right. When the plot
# looks wrong, you'll know it's the CODE that's wrong, not the biology.
# We'll come back to METABRIC at the end, and by then plotting will be the
# easy part.

# Same rules as always: # is a comment, Ctrl+Enter (Cmd+Enter) runs a line.


################################################################################
# SECTION 1: Setup
################################################################################

# Install ONCE. Note these are commented out -- remember the Day 1 rule about
# never leaving install.packages() live in a script you might share.

install.packages(c("ggplot2", "pokemon", "dplyr", "scales", "patchwork", "tidyr"))

library(ggplot2)     # the plotting package
library(pokemon)     # our practice dataset
library(dplyr)       # Day 2 verbs -- we'll use them constantly today
library(scales)      # helpers for formatting axis labels
library(patchwork)   # for gluing multiple plots together
library(tidyr)       # for reshaping data (we need it once, at the end)

# library() calls go at the TOP of the script. Always.

data("pokemon")

#--- ALWAYS look before you plot ---


# Look at colnames() output carefully, because it's about to matter:
#   - the generation column is called generation_id, not generation
#   - there's no single "total stats" column -- we're going to build one
# If you copy code off the internet that says `generation`, it will fail here.
# Column names are the #1 source of errors in R and it's never interesting.

#--- Build the columns we want (Day 2 callback!) ---
# total_points = the sum of a Pokemon's six base stats. That's a mutate().
# generation = generation_id, but as a CATEGORY not a number. Explanation below.


# Why factor()? generation_id is stored as a number: 1, 2, 3...
# But generation 2 isn't "twice" generation 1. It's a label, not a quantity.
# If you leave it numeric, ggplot will hand you a continuous blue color GRADIENT
# for generations, which is nonsense, and some plots will refuse to run at all.
# factor() tells R "these are categories that happen to look like numbers."
# You will hit this exact problem with cancer stage. Remember it.



################################################################################
# SECTION 2: The Grammar of Graphics
################################################################################

# Most software makes a plot by picking from a menu: pie chart, bar chart,
# scatter plot. ggplot2 doesn't work that way and this trips everyone up
# for about an hour, and then it clicks and you never go back.

# ggplot2 says every plot is made of independent pieces you snap together:

#   1. DATA        -- the data frame
#   2. AESTHETICS  -- which variable maps to which visual property
#                     (x position, y position, color, size, shape)
#   3. GEOMS       -- the actual marks on the page (points, bars, lines)
#   4. SCALES      -- how data values translate into those visuals
#   5. FACETS      -- split into small side-by-side panels
#   6. THEMES      -- everything that isn't the data (fonts, grids, background)

# There's no "make a scatter plot" function. You say "put attack on x, defense
# on y, and draw points." That combination IS a scatter plot. Swap geom_point()
# for geom_line() and you've made a line chart. Same grammar, different word.

# The payoff: once you know the grammar you can build plots nobody named,
# because you're describing what you want instead of picking from a list.

# THE MOST IMPORTANT SYNTAX RULE TODAY:
#   ggplot2 layers are joined with  +
#   dplyr steps are joined with     |>
# They are NOT interchangeable. Mixing them up is the error you will make
# fifty times this afternoon. When you see
#   "Error: Can't add ... to a <ggplot> object"
# you used |> where you needed +.


################################################################################
# SECTION 3: Your First Plot, One Piece at a Time
################################################################################

# Let's build a scatter plot in slow motion. Run each of these separately and
# watch the Plots pane (bottom right).

#--- Step 1: data only ---


# This is the first layerA gray rectangle. That's it. We told R what data to use and nothing else.
# It has no idea what to draw.

#--- Step 2: add the aesthetic mapping ---


#  Second layer. Now we get axes! There's an attack axis and a defense axis, correctly scaled
# to the range of the real data. But still no points -- we said what the axes
# MEAN, not what to draw on them.

#--- Step 3: add a geom ---


# THERE it is. Three pieces: data, mapping, geom.

# The + at the end of the line means "and add this layer."
# It MUST be at the END of the line, not the start of the next one.
# This is the single most common ggplot syntax error:
  ggplot(pokemon, aes(x = attack, y = defense))
    + geom_point()                                # WRONG -- R runs line 1
#                                                   # and thinks you're done

# For the rest of this class I'll drop `data =` and `mapping =`, because
# they're always the first two arguments anyway:


# Look at the plot. Attack and defense are loosely related, there's a big
# blob in the middle, and some points are stacked directly on top of each
# other because stats are whole numbers. Hold that thought.

# Try it yourself: make a scatter plot of speed vs total_points.



################################################################################
# SECTION 4: Aesthetics - Mapping Variables to Visuals
################################################################################

# A scatter plot shows two variables. But we have more than two. Aesthetics
# let you push extra variables into color, size, and shape.

#--- Adding a third variable with color ---


# Three variables in one plot, and a legend appeared automatically. You never
# asked for a legend. ggplot2 built it because you mapped a variable to color.

#--- THE MOST IMPORTANT RULE OF THE DAY ---
# Look very carefully at where things go in that line:
#     color = type_1      is INSIDE aes()
#     size = 2, alpha = 0.6  are INSIDE geom_point(), not aes()

# The rule:
#   INSIDE aes()  = "this visual property DEPENDS ON a column in my data"
#   OUTSIDE aes() = "set this property to this fixed value for everything"

# Watch what happens when you get it wrong. This is the classic:

# The boxes came out salmon-colored-ish, there's a pointless legend on the
# right labeled "coral", and it didn't do what you wanted. Why?
# You put fill = "coral" inside aes(), so ggplot thought "coral" was DATA.
# It made an invisible column where every row says "coral", mapped that
# one-category column to fill, picked its own default color for it, and
# built you a legend explaining it. It did exactly what you asked.

# Here's the fix -- fill moves OUTSIDE aes(), into the geom:


# Real coral. No legend. When you see a legend you didn't want, with one
# entry named after a color, you know exactly what you did.

#--- Global vs local ---
# Aesthetics in ggplot() are GLOBAL -- every layer inherits them.
# Aesthetics in a geom_*() are LOCAL -- only that layer uses them.

# Global color: both layers get colored by type
     # a trend line PER TYPE (18 lines!)

# Local color: only the points get colored, so the trend line is one line


# Same data, completely different message, and the only difference is which
# set of parentheses `color` lives in. Run both. Understand the difference.
# This one detail causes more confusion than anything else in ggplot2.

#--- Other things you can map ---
?geom_point     # scroll to "Aesthetics" to see everything geom_point accepts

# size: bigger point = bigger value


# shape: for categories (max ~6 before it gets silly)


# Fixed shapes are numbered 0-25. Try 12:



################################################################################
# SECTION 5: One Variable - Histograms and Density
################################################################################

# Not every question needs two variables. "What does attack look like across
# all Pokemon?" is a one-variable question.

#--- Histogram ---


# Notice: we gave it NO y. A histogram invents its own y.
# It chops x into bins, counts how many rows land in each bin, and the count
# becomes the height. That counting is a "statistical transformation" -- the
# geom did math for you before drawing. Not all geoms just draw what you gave
# them, and knowing which is which saves you a lot of confusion.

# It also printed a message telling you to pick a better bin count. So:


# Run all three. Same data, three different stories:
#   8 bins   -- smooth, clean, hides everything interesting
#   100 bins -- spiky noise, every bump looks meaningful, none of them are
#   30 bins  -- about right
# THE BIN COUNT IS A CHOICE YOU ARE MAKING and it changes what people conclude.
# Try a few. Don't just accept the default.

# Note fill vs color on a histogram:
#   fill  = the inside of the bars
#   color = the outline
# For anything with area (bars, boxes, violins), fill is what you usually want.
# For points and lines, color is the one.

#--- Adding labels ---


# labs() controls every piece of text. An unlabeled plot is not a finished
# plot. "attack" on an axis is what the COLUMN is called; "Base Attack Stat"
# is what a HUMAN needs. Nobody except you knows what your column names mean.

#--- Density plot: the smooth version ---


# Same shape, no bins to argue about. The y-axis is now "density" instead of
# "count", which means the area under the curve is 1. It's a trade: you lose
# "how many" and gain "what shape".

# Density really earns its keep for comparing groups:


# Note I filtered first. Try it with all 18 types and see the mush -- that's
# the lesson. Overlapping densities work for 2-5 groups. Past that it's soup,
# and we'll need facets (Section 8).

# Also note HOW I filtered: pokemon |> filter(...) piped straight into ggplot.
# Day 2 and Day 3 snap together. More on this in Section 6.



################################################################################
# SECTION 6: Comparing Groups - Boxplots and Violins
################################################################################

# "Does attack differ by type?" -- one categorical variable, one numeric.
# This is the single most common plot shape in biology.

#--- Boxplot ---


# How to read a boxplot:
#   the line in the box  = MEDIAN (not the mean!)
#   the box              = middle 50% of the data (25th to 75th percentile)
#   the whiskers         = most of the rest
#   the dots             = outliers
# A tall box means the group is spread out. A short box means it's consistent.
# geom_boxplot() calculated all of that from raw data. You didn't compute
# a single quartile. Compare that to the summarise() gymnastics on Day 2.

# coord_flip() swaps the axes. With 18 type names on the x-axis they overlap
# into an unreadable smear; flipped, they're a clean readable list.
# Delete the coord_flip() line and look. Then put it back.

#--- Violin plot ---

# A violin is a density plot mirrored and turned sideways. Wide = lots of
# Pokemon at that attack value.

# Why bother? Because a boxplot can lie to you. Two groups with identical
# medians and identical quartiles can have completely different shapes --
# one clustered in the middle, one piled up at both ends with a hole in the
# middle. The boxplots look the same. The violins do not. The boxplot is a
# summary; the violin is closer to the truth.

# Note fill = type_1 is inside aes() here and that's CORRECT -- fill genuinely
# depends on a column this time. Same argument, different parentheses,
# different meaning. It always comes back to this.

#--- Layering: violin AND boxplot ---


# LAYERS ARE DRAWN IN ORDER, like stacking transparencies. Violin first, then
# boxplot painted on top. Swap the two lines and the violin covers the box.
# Full distribution shape AND the summary statistics, in one plot. This is
# what the grammar buys you -- no one designed a "violin-with-box" chart type.
# You just stacked two geoms.

#--- Piping data into ggplot ---
# Notice what I keep doing:


# Read it: take pokemon, AND THEN filter, AND THEN plot... AND +geom.
# Look hard at where the syntax switches. |> all the way up to ggplot(),
# then + forever after. The pipe hands the data in; once you're inside a
# ggplot, you're adding layers. Get this wrong and R will tell you it can't
# add things to a ggplot object.

# This is huge in practice: filter/mutate/summarise your data and plot it in
# one uninterrupted chunk of code, with no junk objects cluttering your
# Environment. Your data prep lives right next to the plot it's for.

# Try it yourself: make a boxplot of total_points by generation. Are later
# generations of Pokemon better? (Careful with fill and factors.)



################################################################################
# SECTION 7: Geoms That Do Math For You
################################################################################

#--- Bar charts count things automatically ---


# Again, no y! geom_bar() counted the rows in each type for you.
# It is doing exactly what Day 2's count() does, then drawing the answer:


#--- geom_bar vs geom_col ---
# If you ALREADY have the numbers, you don't want geom_bar() counting again.
# geom_col() draws the heights you give it:


#   geom_bar() = "count these rows for me"  (needs only x)
#   geom_col() = "here are the heights"     (needs x and y)
# "Error: stat_count() can only have an x or y aesthetic" means you handed
# geom_bar() a y. You wanted geom_col().

#--- stat_summary: means and error bars ---


# stat_summary() computes a statistic per group on the fly:
#   fun = mean          -- calculate the mean, draw it as a bar
#   fun.data = mean_se  -- calculate mean +/- standard error, draw as errorbar
# Two layers, one plot: heights and uncertainty.

# You could do this with group_by() |> summarise() |> geom_col() and get the
# same picture. Both are fine. Do it with dplyr when you also want the numbers
# in a table; do it with stat_summary() when you only want the plot.

# HONEST WARNING: this bar-with-error-bars plot is everywhere in biology
# papers and it's a mediocre way to show data. It reduces a whole group to two
# numbers and hides the shape completely. If you have room, show the violin.
# The bar chart is a habit, not a decision.

#--- geom_smooth: trend lines ---


#   method = "lm"    -- fits a straight line (linear regression)
#   method = "loess" -- fits a wiggly local curve that follows the data
#   se = TRUE        -- shaded confidence band around the line
# Two smooths at once lets you ask "is a straight line good enough here?"
# If the blue curve wanders far from the red line, the answer is no.

# The shaded band is the uncertainty in the LINE, not the spread of the data.
# It gets narrow where you have lots of points. A narrow band does not mean
# a strong relationship -- it means you're confident about a possibly-weak line.



################################################################################
# SECTION 8: Scales - Controlling the Mapping
################################################################################

# aes() says WHICH variable maps to color. scale_*() says HOW.
# Every aesthetic gets a default scale automatically. Scales let you override.

# Naming pattern: scale_<aesthetic>_<type>()
#   scale_color_gradient()   -- color, continuous
#   scale_fill_manual()      -- fill, you pick each one
#   scale_x_continuous()     -- x axis, numeric
#   scale_y_log10()          -- y axis, log transformed

#--- Continuous color gradients ---


# scale_color_gradient() -- blue for low speed, red for high, blended between.
# scale_x_continuous(breaks = ...) -- where the tick marks go. seq(0, 200, 25)
# is Day 1 material, still doing work.

#--- Manual colors for categories ---


# scale_color_manual() lets you name each color yourself. Those #F08030 things
# are hex codes -- red/green/blue in base 16. You don't need to memorize them;
# you look them up. These are the real Pokemon type colors.

# The values are a NAMED vector, which matters: fire = "#F08030" pins that
# color to that category no matter what order they appear in. If you just
# gave it four colors with no names, they'd be assigned alphabetically and
# your fire Pokemon would come out blue.

# When would you use this for real? When color has meaning your audience
# already knows: tumor vs normal always the same two colors across every
# figure in your paper.

#--- Color-blind safe palettes ---


# scale_size_continuous(range = c(1, 15)) sets the smallest and largest points.
# scale_color_viridis_d() is the viridis palette. The _d means DISCRETE
# (categories); _c would be CONTINUOUS (numbers). Get this wrong and R will
# complain that you're using a discrete scale for continuous data.

# Use viridis. Roughly 8% of men have some form of color blindness, and the
# default red/green ggplot palette is genuinely unreadable to a chunk of your
# audience. Viridis is designed to survive color blindness AND to still work
# when someone prints your figure in black and white. It costs one line.



################################################################################
# SECTION 9: Themes - Everything That Isn't Data
################################################################################

# Themes control fonts, gridlines, backgrounds, legend position -- every
# non-data element. Zero effect on what the data says. Big effect on whether
# anyone takes it seriously.

#--- Built-in themes ---
p <- ggplot(pokemon, aes(x = type_1, y = attack)) +
  geom_boxplot(fill = "lightblue", alpha = 0.6) +
  coord_flip()

# We just saved a plot as a variable! It's an object like any other. Nothing
# displayed until we ask. Now we can bolt different themes onto the same base:
p + theme_bw()        + labs(title = "theme_bw()")
p + theme_minimal()   + labs(title = "theme_minimal()")
p + theme_classic()   + labs(title = "theme_classic()")
p + theme_dark()      + labs(title = "theme_dark()")
p + theme_void()      + labs(title = "theme_void()")

# theme_bw()      -- black and white, clean, safe for print
# theme_minimal() -- no border, faint gridlines. My default.
# theme_classic() -- axis lines only, looks like base R / old-school papers
# theme_dark()    -- dark background, occasionally useful for bright points
# theme_void()    -- nothing at all. For maps and diagrams.

# That gray background with white gridlines is the ggplot2 default and it
# screams "I didn't change anything." Same energy as leaving RStudio on the
# default theme. YOU KNOW HOW I FEEL ABOUT THAT.

#--- Set a theme for the whole session ---
theme_set(theme_minimal())

# Every plot from here on uses it. One line at the top of your script and
# your whole analysis looks consistent. Do this.

#--- Custom theme elements ---
ggplot(pokemon, aes(x = attack, y = defense, color = type_1)) +
  geom_point(size = 2, alpha = 0.6) +
  theme_minimal() +
  theme(
    # text
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, face = "italic", hjust = 0.5),
    axis.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 10),

    # legend
    legend.position = "bottom",
    legend.title = element_text(size = 11, face = "bold"),
    legend.text = element_text(size = 9),

    # gridlines
    panel.grid.major = element_line(color = "gray80", linewidth = 0.5),
    panel.grid.minor = element_blank(),

    # backgrounds
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "gray95", color = NA)
  ) +
  labs(title = "Customized Theme Example",
    subtitle = "Complete control over plot appearance")

# The pattern: theme(what_to_change = element_type(how_to_change_it))
#   element_text()  -- anything made of words
#   element_line()  -- gridlines, axis lines, ticks
#   element_rect()  -- backgrounds, legend boxes
#   element_blank() -- DELETE THIS ELEMENT ENTIRELY
# hjust = horizontal justification: 0 left, 0.5 center, 1 right.

# element_blank() is the one you'll reach for most. panel.grid.minor =
# element_blank() removes the faint half-gridlines and instantly declutters
# almost any plot.

# Note theme_minimal() comes FIRST, then theme(). Order matters: theme_minimal()
# resets everything, then your theme() tweaks it. Flip them and theme_minimal()
# wipes out your custom work. Broad strokes first, details second.

# Don't memorize this list. Nobody has. You Google "ggplot rotate x axis
# labels", find theme(axis.text.x = element_text(angle = 45, hjust = 1)),
# paste it, move on with your life. That's not cheating, that's the job.



################################################################################
# SECTION 10: Combining Plots with patchwork
################################################################################

# Real figures in real papers have panels A, B, C, D. patchwork makes that
# almost insultingly easy.

plot_a <- ggplot(pokemon, aes(x = attack)) +
  geom_histogram(bins = 30, fill = "coral") +
  labs(title = "Attack Distribution")

plot_b <- ggplot(pokemon, aes(x = defense)) +
  geom_histogram(bins = 30, fill = "lightblue") +
  labs(title = "Defense Distribution")

plot_c <- ggplot(pokemon, aes(x = attack, y = defense)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Attack vs Defense")

plot_d <- ggplot(pokemon, aes(x = type_1, y = attack)) +
  geom_boxplot(fill = "lightgreen", alpha = 0.6) +
  coord_flip() +
  labs(title = "Attack by Type")

# Now combine them with two operators:
#   |  side by side
#   /  stacked
#   () groups things, exactly like in math

    # 2x2 grid
      # one on top, three below
  # three on top, one spanning below

# That's it. That's the whole package. It's using the same intuition as
# order of operations -- the parentheses control the grouping.

#--- Annotating the whole figure ---
combined_final <- (plot_a | plot_b) / (plot_c | plot_d) +
  plot_annotation(
    title = "Pokemon Statistics Overview",
    subtitle = "Distributions, relationships, and group comparisons",
    caption = "Data source: pokemon package",
    tag_levels = "A"
  )

combined_final

# plot_annotation() titles the whole figure rather than one panel.
# tag_levels = "A" auto-labels the panels A, B, C, D -- so when your figure
# legend says "(C) attack versus defense", the letters are already there and
# they stay correct when you rearrange the layout. Small thing. Saves hours.



################################################################################
# SECTION 11: Ordering Your Categories (this one matters)
################################################################################

# Look again at any of the by-type boxplots. The types are in alphabetical
# order: bug, dark, dragon, electric... Alphabetical order is meaningless.
# Nobody cares which type starts with 'b'.

# R sorts categories alphabetically because it has no idea what else to do.
# But YOU know what else to do -- sort by the thing you're plotting:



# reorder(type_1, attack, FUN = median) reorders the type categories by each
# type's median attack. Now the plot has a shape. The strongest and weakest
# types are at the ends where your eye lands, and the ranking is readable
# instantly instead of requiring the reader to scan and mentally sort.

# Run it with and without that mutate() line, back to back. The difference in
# readability is enormous and the cost is one line. This is the highest
# effort-to-payoff ratio in this entire lesson.



################################################################################
# SECTION 12: Saving Your Plots
################################################################################

# The Export button in the Plots pane works. Don't use it.
# It's a click, so it isn't saved, so it isn't reproducible, and when your
# advisor asks for the figure at 600 dpi you get to click through it again.

# ggsave("pokemon_attack_defense.png", width = 10, height = 6, dpi = 300)

# With no plot = argument it saves THE LAST PLOT YOU DISPLAYED.
# Be careful with that. Better to be explicit:

# ggsave("figure_1.png", plot = combined_final, width = 12, height = 8, dpi = 300)

# ggsave() reads the format off the file extension:
#   .png  -- pixels. Fine for slides and drafts.
#   .pdf  -- VECTOR. Infinitely scalable, never pixelated. Use for papers.
#   .tiff -- what journals demand, usually at 300 or 600 dpi
#   .svg  -- vector, editable afterward in Illustrator/Inkscape

# ggsave("figure_1.pdf", plot = combined_final, width = 12, height = 8)

# width/height are in INCHES and they control the whole look. Text does NOT
# scale with the plot -- make the plot twice as wide and the labels stay the
# same physical size, so they LOOK smaller. If your saved figure has tiny
# unreadable text, your dimensions are too big. Iterate: save, look at the
# actual file, adjust. Do not judge by the Plots pane; it's lying to you
# about the aspect ratio.

# Remember Day 1: files go to your working directory. That's why we set up
# the project folder.




################################################################################
# SECTION 15: Getting Help
################################################################################

?geom_point                   # scroll to "Aesthetics" for what it accepts
?aes
?theme
example(geom_boxplot)

# ggplot2's own documentation is genuinely good:
#   https://ggplot2.tidyverse.org/reference/     -- every function, with pictures
#   https://r-graph-gallery.com/                 -- "what's it called?" -> code
#   https://ggplot2-book.org/                    -- Hadley Wickham's free book

# The R Graph Gallery is the one to bookmark. When you know what you want but
# not what it's called, scroll the pictures until you see it, take the code.

# Cheat sheet: Help -> Cheat Sheets -> Data Visualization with ggplot2
# Print it. Keep it next to the dplyr one.

# vignette("ggplot2-specs")   # every color, shape, and linetype option



################################################################################
# CONGRATULATIONS
################################################################################

# THE GRAMMAR:
#   ggplot(data, aes(...)) + geom_*() + scale_*() + facet_*() + theme_*() + labs()

# WHICH GEOM?
#   one numeric variable            -> geom_histogram, geom_density
#   one categorical                 -> geom_bar
#   numeric x numeric               -> geom_point, geom_smooth, geom_hex
#   categorical x numeric           -> geom_boxplot, geom_violin, geom_col
#   two categorical + a value       -> geom_tile (heatmap)
#   over time                       -> geom_line

# THE THINGS THAT WILL ACTUALLY BITE YOU:
#   - Layers join with +. dplyr joins with |>. Not interchangeable.
#   - INSIDE aes() = depends on data. OUTSIDE aes() = fixed value.
#     (Mystery legend named "coral"? You put a color inside aes().)
#   - Numbers that are really categories need factor().
#   - Alphabetical order is the default and is almost never right. reorder().
#   - Bin count, axis limits, and free scales are CHOICES that change the story.
#   - Use viridis. Some of your audience can't see your red/green plot.
#   - Label your axes. Column names are not English.
#   - Solid overlapping points hide your sample size. Use alpha.
#   - ggsave() with explicit dimensions. Not the Export button.

# AND THE BIG ONE:
#   ggplot2 will make anything you ask for, and it will look professional
#   whether or not it's true. A polished figure is more persuasive than an
#   ugly one -- including when it's wrong. That's not a reason to make ugly
#   figures. It's a reason to be the person who checks.

# Next steps:
#   - Joins: combining clinical data with mutation data
#   - pivot_longer / pivot_wider properly (we only touched it today)
#   - Survival curves, and doing censoring RIGHT
#   - Volcano plots and heatmaps on real expression data
#   - Extensions: ggrepel (non-overlapping labels), ggridges, gganimate


################################################################################
# Day 3 Review: ggplot2 Practice Problems
# Cancer Bioinformatics Workshop
################################################################################

# These use the SAME dataset from the lessons: brca_metabric_clinical_data.
# Make sure it's loaded before you start.

# Each question describes WHAT we want to see, not how to build it. Picking the
# right geom -- and getting the details right -- is the whole exercise.

library(ggplot2)
library(dplyr)

# Before you start, a few reminders that will save you pain:
#   - Layers join with  +  . dplyr steps join with  |>  . Not interchangeable.
#   - Tumor.Size is in MILLIMETERS.
#   - Some columns have NA or "" (blank) values -- clean before you plot.
#   - When something looks wrong, ask: is this property mapped to DATA, or set
#     to a FIXED value? That decides where it goes.

################################################################################
# QUESTIONS
################################################################################

# --- Q1 ---
# We want to see whether older patients tend to have larger tumors. Show each
# patient as a point, with age at diagnosis on the x-axis and tumor size on
# the y-axis. There are ~2000 patients, so make sure we can actually see where
# they pile up rather than one blob of solid ink.


# --- Q2 ---
# Same scatter of age vs tumor size, but now we want to see whether the
# pattern differs by ER status. Color the points by ER.Status.


# --- Q3 ---
# Show the distribution of age at diagnosis across all patients as a histogram.
# Give the bars a filled color with a clean outline so individual bars are easy
# to tell apart. Add a real title and axis labels.


# --- Q4 ---
# Compare tumor size across the four tumor stages using boxplots. Make all the
# boxes the same shade of steel blue. Label it properly.


# --- Q5 ---
# Now compare tumor size across stages using violins instead, and this time
# give each stage its OWN color so they're visually distinct.


# --- Q6 ---
# We want a boxplot of survival months for each tumor stage. Ignore patients
# with a missing stage. (This one has a catch -- if your stages come out on a
# continuous axis or the plot refuses to group them, think about what type of
# variable stage really is.)


# --- Q7 ---
# Take any plot you've made and dress it for a presentation: add a title, a
# subtitle, clearly worded x and y axis labels, and a caption noting the data
# source. The point of this question is the text, not the geom.


# --- Q8 ---
# Make a boxplot of tumor size by stage, then apply a clean minimal theme,
# and get rid of the gray default background. Bonus: the legend here is
# redundant with the x-axis -- remove it.


# --- Q9 ---
# Boxplots of age at diagnosis for each detailed cancer type
# (Cancer.Type.Detailed). By default the types come out in alphabetical order,
# which tells us nothing. Reorder them so the plot ranks the types by their
# median age -- so the pattern is readable at a glance.


# --- Q10 ---
# The capstone. Among patients who DIED of their disease, show the distribution
# of survival months for each PAM50 subtype