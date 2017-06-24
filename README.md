---
title: The garden
author: 'Bryan Whiting'
---

The garden is a minimalist, full-circle planning and reporting tool, designed to help you dream big, plan small, execute, and reflect. Because you deserve to not only do stuff, but become someone.

## Why

I wanted a scrum for my personal life, but I didn't find it practical to use the many online resources available. I investigated many, such as [craft.io](https://craft.io/), and [Taiga](https://taiga.io/). While these are great for product development, I still didn't think they met my needs as someone who wants to include both a trip to the grocery store as well as writing a blog post in my backlog. My life isn't quite a product, but I'd like to get things done in a similar way - dream, plan, execute, and reflect.

## How

The `garden` is based on the principles that when you plan, you should have a set day when you report. That planning should happen monthly, weekly, and daily. Planning shouldn't be overwhelming, but as simple as possible. You should plan and report each day, even if for 60 seconds. You should plan and report each week, even if for 5 minutes. And most importantly, you should have a vision for why you're doing things. Each phase of planning involves taking the time to craft in your mind exactly who you want to become.

You need some place to journal. I like doing everything in the command line, so I use [jrnl](http://jrnl.sh/).

## What do I do?

The `garden` is a metaphor for planning. Think of your life as a garden. There are seeds to plant, there's a period to cultivate and harvest. There are seasons. It's helpful for me to not make a "plan", but rather to "plant a seed". Planning is dry. Planting seeds is creation.


### Journaling
Here's how the system works. Anytime you see an "@" symbol, that's a phase of the garden. Here's how I define things:

|Phase|Description|
|---|---|
|season|Monthly planning session. 15-30 min|
|garden|Weekly planning. 15 min|
|sunrise|Morning planning. 2-3 min|
|seeds|One-and-done weekly plans|
|streams|Repeat plans (think: daily habits)|

The reason I give each phase a name is because there's a feedback loop for each phase. For example, you'll write a once-a-month \@vision statement that you'll return to each week during your weekly planning. And each day, you'll reflect on the \@field, which is created during your weekly planning. Here are the planning sessions, do each of these things in your journal.

Once a month planning (the \@season):
* @fall
  * Reflect on @seeds and @streams. How have they changed you? 
* @vision
  * In different areas of life (personal, work, family, etc). (5 min each) 
    * Where have I come from? 
    * Where do I feel my current trajectory is taking me? 1, 3, 10 years. 
    * What do I dream of accomplishing and becoming? 
    * Is my current path taking me there? Do I need to change anything in order to get there?
  * What talents, skills, or hobbies do I want to acquire?
* @spring: this month, what will I do to achieve the @vision?
  * @theme: Pick a theme for the week
  * Outline main objectives
    * Become: One attribute I want to cultivate. 
    * Create: One skill, hobby, talent I want to hone. 
    * Connect: One way to connect personally with family, friends, and colleagues.
  * Add @streams

Once-a-week planning (the \@garden):
* @harvest: 
  * a weekly @sunset. Review how doing things in the @field have affected you. 
* @waterfall:
    * Review @streams. How are these streams affecting you?
* @pond: Reflect on everything. Dreams, goals, aspirations.
    * Review @vision.
* @field: plant @seeds for the week in each @field. Only 3 fields per week.
    * Review @spring
    * Outline main crops (focuses)
        * Spiritual
        * Family
        * Self
    * Add @seeds: What specific things will you do? Must be binary.
    * Add @streams.

Daily:
* @sunrise 8am: 5 min.
    * Review the @field.
    * Write your thoughts on the day. What you hope to accomplish in the day. What you want to learn. What you’re looking forward to. 
    * Plant @seeds. Specific goals you’ll accomplish that day.
* @thepark: 1 min every hour. What are you learning? Are you accomplishing your goals?
* @sunset 8pm: 5 min.
    * @streams: log goals
    * Review @seeds from @sunrise.
    * What’d you learn. Add to the @harvest.
    
    
### R code (planning)

None of the above requires the `garden` script. Once you do your respective journaling for the day, the `garden` will help you organize your goals. 

Add the following command to your `.bashrc` and adjust the filepath as necessary:

```
g() {
    RScript --vanilla ~/github/the-garden/garden.R $@;
}
```

After you source your `.bashrc` file (or restart the terminal), you can use the terminal to track your goals.

#### Seeds
A seed is a one-time goal. They last from Sunday through Saturday at midnight. If you add a seed on Wednesday, it expires on Saturday. Here's how you add a seed:

```
g -seed <seed-name> <seed-description>
```

`<seed-name>` must only be one word, but `<seed_description>` can be multiple words. If you only specify `g -seed` and no name or description, the terminal will prompt you for a name and description.

```
> g -seed exercise run 30 minutes
```

To see the seeds for the week, just type `g` with no commands. I've added a few others:

```
| id |   seed   |              desc               |  planted   | harvested date | 0/4 |
|:--:|:--------:|:-------------------------------:|:----------:|:--------------:|:---:|
| 1  |  blogs   |          post 3 blogs           |     NA     |       NA       |  0  |
| 2  | workout  |          run 30 minutes         |     NA     |       NA       |  0  |
| 3  | register |       register for class        |     NA     |       NA       |  0  |
| 4  |   draw   |         finish drawing          |     NA     |       NA       |  0  |
```

You'll notice there are a few extra columns. An `id` column, a `planted` column, a `harvested date` column and a rate. I'll describe that later.


#### Streams
A stream is something you want to do every day for a number of days. (Say you want to form a habit.)

```
> g -stream <stream-name>
```
You'll be prompted to enter a description and time period:

```
> g -stream cook

> Stream name: cook
> Define your goal (must be binary): <enter description>
> How many days: <specify number of days>
```

If you type `g`, you can now see all your streams and seeds. `thisday` tracks whether you've done it today. `thisweek` counts how many times you've done it this week. `streak` shows your overall progress (10/28 means you've done it 10 days out of the last 28). `left` is how many days left in this stream.

```
|   stream   | thisday | thisweek | streak | left |
|:----------:|:-------:|:--------:|:------:|:----:|
|    cook    |    0    |   4/6    |   0/1  |  10  |
|    read    |    0    |   3/6    |   0/1  |  4   |

| id |   seed   |              desc               |  planted   | harvested date | 0/4 |
|:--:|:--------:|:-------------------------------:|:----------:|:--------------:|:---:|
| 1  |   blogs  |          post 3 blogs           |     NA     |       NA       |  0  |
| 2  |  workout |          run 30 minutes         |     NA     |       NA       |  0  |
| 3  | register |       register for class        |     NA     |       NA       |  0  |
| 4  |   draw   |         finish drawing          |     NA     |       NA       |  0  |
```

> Make sure you only use unique names for seeds and streams. 

#### Logging
Now that you've defined your daily goals, you can track your progress. Use `-l` to log your seeds and streams.

```
> g -l cook blogs
> g

|   stream   | thisday | thisweek | streak | left |
|:----------:|:-------:|:--------:|:------:|:----:|
|    cook    |    1    |   4/6    |   0/1  |  10  |
|    read    |    0    |   3/6    |   0/1  |  4   |

| id |   seed   |              desc               |  planted   | harvested date | 1/4 |
|:--:|:--------:|:-------------------------------:|:----------:|:--------------:|:---:|
| 1  |   blogs  |          post 3 blogs           |     NA     |   2016-06-24   |  1  |
| 2  |  workout |          run 30 minutes         |     NA     |       NA       |  0  |
| 3  | register |       register for class        |     NA     |       NA       |  0  |
| 4  |   draw   |         finish drawing          |     NA     |       NA       |  0  |
```

If you want to log for yesterday, type `g -l1 cook blogs`. If you want to log `#` days ago, use `g -l# cook blogs`.

#### Planting

As part of your sunrise, you may want to assign some goals just for today (to keep extra focus). To do this, plant your seeds with the `-p` option and the appropriate id number. (You can use `g` to refresh yourself on the id numbers).

```
> g -p 2 4
> g
|   stream   | thisday | thisweek | streak | left |
|:----------:|:-------:|:--------:|:------:|:----:|
|    cook    |    1    |   4/6    |   0/1  |  10  |
|    read    |    0    |   3/6    |   0/1  |  4   |

| id |   seed   |              desc               |  planted   | harvested date | 1/4 |
|:--:|:--------:|:-------------------------------:|:----------:|:--------------:|:---:|
| 1  |   blogs  |          post 3 blogs           |     NA     |   2016-06-24   |  1  |
| 2  |  workout |          run 30 minutes         | 2016-06-25 |       NA       |  0  |
| 3  | register |       register for class        | 2016-06-25 |       NA       |  0  |
| 4  |   draw   |         finish drawing          |     NA     |       NA       |  0  |
```

If you type `g -p` without numbers, it'll give you a focused list for today.

```
> g -p

|    name    |             desc             |  type  |
|:----------:|:----------------------------:|:------:|
|   blogs    |         Post 3 blogs         |  seed  |
|   garden   | Make small updates to garden |  seed  |
|   cook     |         Read 30 min          | stream |
|   read     |        Read the news         | stream |
```

As you go about your day and as you finish tasks and log them with `g -l`, you'll see the items disappear from this list. (You may need to refresh with `g` first, as `g` processes the data on the backend.)

## Backend

All of your data are stored in the `folder_path` specified in the `garden.R` file. There's the following folder structure:

```
garden/
|-log.txt
|-streams.txt
|-seeds/
|--2017-06-18-seeds.txt
|--2017-06-11-seeds.txt
```

There's a `seed` file for each week, which is how your seeds 'expire'. The `g` function processes the `streams` in such a way that there's no need to worry about having a dated file. 

The `field_day` variable defines what day you want to start the seeds, which means your seeds will expire 6 days later. By default, this is Sunday.

## Bringing it all together

Each morning, you open your terminal and journal up a \@sunrise. Then you type `-g` to see what your pending goals are for the week. You can plant them with `g -p #` and use `g -p` to get a focused list that combines your todos for the day (merging both \@seeds and \@streams). Each week, you create a \@garden that contains your \@seeds and \@streams. 

Each day you both log your accomplishments using the `garden` and journal on your progress. Not only tracking, but having a mental dialogue about what went well, what didn't and what you'd do tomorrow or next time will increase the rate at which you progress. The `garden` forces you to step outside of yourself, step back from the weeds, see the big picture, design your life, and then dive back into the weeds to get things done.

## Future work
Here's where I see the project going, if other's are interested in helping:

[] Create a setup.R file that installs the necesseary packages
[] Bug: update `g -p` so that it refreshes without needing to first run `g`
[] Add ability to add \@seeds for next week (right now you can only do seeds for this week)
[] Add ability to compile the garden for last week (right now you can only compile the garden for this week)
[] Do this in Python so that it can have a wider distribution (Macs come pre-loaded)

## License

Currently there is no open-source license for this code, but you are free to use the `garden` for personal use. If you wish to use it for commercial reasons, please reach out to me.