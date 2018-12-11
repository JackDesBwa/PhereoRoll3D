PhereoP83D
==========

I was frustrated to not be able to use native autostereoscopic capabilities of my ELEPHONE P8 3D to watch stereophotographs of Phereo website ; so I made this app to display them nicely.

Status: Proof of concept — It is working and I might improve depending of my needs

Usage
-----

First, you need this phone, since it is primary intended for it. When the phone is in landscape mode, the app displays itself in column-interleaved to be in 3D thanks to autostereoscopic display.

The app opens "Popular" list at startup.

### List view

This view lists all images of the currently selected category/user/album (only first items are loaded, but you can load more images).

![List view](screenshots/screenshot_list.png)

(1)
Tabs to access Phereo's categories.
The current tab is underlined

(2)
Currently selected category/user/album

(3)
Current image number / Total images in the list.
A + sign is appended if there are more images in the list.
Clicking on the text loads next images.

(4)
List of images' thumbnails. Swipe to view all.

(5)
Current image thumbnail.
Click to view

(6)
Statistics of photos in categories.
It is limited to loaded images.

(7)
Informations about selected image (title, author, date, likes, views, comments).
Clicking on the author opens user photos.

### Photo view

This view shows the photograph and some of its metadata, including comments.

![Photo view - simple](screenshots/screenshot_photo_simple.png)

(1) Left edge

Click: Previous image in the current list

Slide up/down: Change zoom (when slide is started, you can go to the right of the screen to have finer control)

Two fingers: reset scale

(2) Rigt edge

Click: Next image in the current list

Slide up/down: Change divergence/z axis origin (when slide is started, you can go to the left of the screen to have finer control)

Two fingers: reset divergence

(3) Top edge

Click: Go to list

Slide or two fingers: Swap left/right

(4) Bottom edge

Click or slide: open infos

Two fingers: Reset image position

(5) Central zone

Use pinch to zoom/move image

![Photo view - infos](screenshots/screenshot_photo_info.jpg)

The information about image are

- Avatar of author (clicking on it opens user photos)
- Name of image
- Name of author (clicking on it opens user photos)
- Date of publication
- Number of likes, views, comments
- Optionally, categories of the photo (Popular, Featured, Staff)
- Description of image
- Currently selected category/user/album +  current image number / Total images in the list.
  A + sign is appended if there are more images in the list.
  Clicking on the text loads next images.
- Optionally, the list of tags
- Optionnally, the list of albums in which the image is (clicking on it opens the album)

Clicking on the information zone opens comments if present.

![Photo view - infos](screenshots/screenshot_photo_comments.jpg)

Each comment has the avatar of its author, the date and the comment itself.

Clicking on the author name or avatar opens its gallery.

Stereo screenshots
------------------

Cross view
![Photo view - stereo screenshot X](screenshots/screenshot_stereo_X.jpg)

Parallel view
![Photo view - stereo screenshot P](screenshots/screenshot_stereo_P.jpg)

Licence
-------

MIT License

Copyright (c) 2018 JackDesBwa

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
