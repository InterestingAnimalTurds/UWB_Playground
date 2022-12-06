# UWB_Playground

### 1.校准与更新库文件（顺便设置Anchor）：

为了使用auto calibration去获得更精确的数据，你需要将原本DW1000库的源文件替换成，auto calibration 的开发者Jim Remington的源文件库（github地址：https://github.com/jremington/UWB-Indoor-Localization_Arduino/tree/main/DW1000_library/src）

替换路径：

1. Windows Arduino Lib Path（C:\Users\...Documents\Arduino\libraries\DW1000\src）
2. MacOS Arduino Lib Path(~/Documents/Arduino/libraries/DW1000/src)

在替换之后，便可以开始校准了。

校准分为两步，并且只有Anchor端需要校准。

1. 校准第一步是通过上传自动校准文件（[UWB_Playground](https://github.com/InterestingAnimalTurds/UWB_Playground/tree/master)/[esp32-tag-anchor](https://github.com/InterestingAnimalTurds/UWB_Playground/tree/master/esp32-tag-anchor)/**ESP32_anchor_autocalibrate**/ESP32_anchor_autocalibrate.ino）到一个Anchor上，通过设定**标准距离**和**预设延迟数**供Anchor自动计算获得**最佳的延迟数**。

```c++
//ESP32_anchor_autocalibrate.ino 中的 32-36行

char this_anchor_addr[] = "03:00:00:00:00:00:03:03";
//这行是你的Anchor地址，即使在校准中也要保证每个Anchor有不同的ADDR
//请用：03:00:00:00:00:00:03:03 -> Anchor 3
//请用：04:00:00:00:00:00:04:04 -> Anchor 4
float this_anchor_target_distance = 1;
//这个则是标准距离，单位为米。一定要使用1米或者2米的整数。别填小数，越远越准。
uint16_t this_anchor_Adelay = 16600; 
//预设延迟数，在上传代码后，anchor会通过Serial port向电脑输出一个最佳延迟数。你需要把它记在纸上。
uint16_t Adelay_delta = 100; 
//屌用没有，可以改成25，我用的就是25
```

2. 现在你应该获得了一个Anchor的**最佳延迟数**， 你需要做的是记下标准距离和那个最佳延迟数。他们会被用到你的Anchor**正式工作代码**时。正式工作代码地址：（[UWB_Playground](https://github.com/InterestingAnimalTurds/UWB_Playground/tree/master)/[ESP32_UWB_setup_anchor](https://github.com/InterestingAnimalTurds/UWB_Playground/tree/master/ESP32_UWB_setup_anchor)/**ESP32_UWB_setup_anchor.ino**）

   ```c++
   //这是Anchor正式代码中的你需要修改的地方，12-24行
   
   char anchor_addr[] = "03:00:00:00:00:00:03:03";
   //这行是你的Anchor地址，即使在校准中也要保证每个Anchor有不同的ADDR
   //请用：03:00:00:00:00:00:03:03 -> Anchor 3
   //请用：04:00:00:00:00:00:04:04 -> Anchor 4
   uint16_t Adelay = 16599;
   //这里需要填入你的刚刚获得的最佳延迟数，现在的最佳延迟数，是我校准出来的。大差不差吧，妈的。
   // previously determined calibration results for antenna delay
   // #1 16630
   // #2 16610
   // #3 16607
   // #4 16580
   
   // calibration distance
   float dist_m = 1.0; //meters
   //这里是填你标准距离的地方，填你刚刚的。
   ```

3. 以上操作，把Anchor3和Anchor4校准和上传后，就可以设置Tag了。

### 2.设置Tag：

Tag文件位置（[UWB_Playground](https://github.com/InterestingAnimalTurds/UWB_Playground/tree/master)/[esp32-tag-anchor](https://github.com/InterestingAnimalTurds/UWB_Playground/tree/master/esp32-tag-anchor)/[uwb-tag](https://github.com/InterestingAnimalTurds/UWB_Playground/tree/master/esp32-tag-anchor/uwb-tag)/**uwb-tag.ino**）

1. 选择TAG的代码块，只需要用一个贼简单的方式（你再也用不到这个文件里的Anchor里的代码了，你刚刚已经设置好Anchor了）

```c++
//第4-5行，注释掉 #define IS_ANCHOR，只Define IS_TAG
#define IS_TAG 
//#define IS_ANCHOR
```

2. 设置Tag和它的网络信息

```c++
#define DEVICE_ADDRESS "01:00:00:00:00:00:01:01"
//地址，TAG的。就用这个得了
#ifdef IS_TAG
  // The tag will update a server with its location information
  // allowing it to be remotely tracked
  // Wi-Fi credentials 
   
   const char *ssid = "linksys"; 
// 你的WIFI名字
   const char *password = "UNXUEWA2";
// 你的WIFI密码。
  // // IP address of server to send location information to
   const char *host = "192.168.1.105"; 
//这里有点Tricky。首先这个是你电脑的在这个WIFI里的IP地址，我强烈希望你能把IP固定。详情在后面。
   int portNum = 52520;
//Python脚本会听这个端口，就用这个吧，别变了
```

3. 还有一处要修改，因为我从学校借的路由器没有密码，所以这里我填的NULL，你需要改成password。

```c++
//文件的第104行，
 WiFi.begin(ssid, NULL);
//改成这个
Wifi.begin(ssid,password);
```

4. 好了上传完了。可以开搞了。

# 开搞：

在你安置好了所有的Anchor和Tag，把你的电脑连上了同样的WiFi, 确认好了IP地址是对的，你就可以开始使用他们了。

1. 首先要开启一个python脚本，这个脚本的目的是将json数据转成OSC数据发给Max8。并且做了一些简单的滤波的计算。

   文件地址（[UWB_Playground](https://github.com/InterestingAnimalTurds/UWB_Playground/tree/master)/[UWB-python-server](https://github.com/InterestingAnimalTurds/UWB_Playground/tree/master/UWB-python-server)/**udpserver.py** ）

   当你能看到，有数据输出的时候，就可以进行下一步了。

2. 使用Max8界面：

![image-20221206010759313](C:\Users\16198\AppData\Roaming\Typora\typora-user-images\image-20221206010759313.png)

----

