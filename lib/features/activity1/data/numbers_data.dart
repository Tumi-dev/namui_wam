import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:namui_wam/features/activity1/models/number_word.dart';

class NumbersData {
  static final List<NumberWord> numbers = [
    // Nivel 1: Números del 1 al 9
    NumberWord(
      number: 1,
      word: 'Kan',
      audioFiles: ['1.Kan.wav'],
      level: 1,
    ),
    NumberWord(
      number: 2,
      word: 'Pa',
      audioFiles: ['2.Pa.wav'],
      level: 1,
    ),
    NumberWord(
      number: 3,
      word: 'Pøn',
      audioFiles: ['3.Pøn.wav'],
      level: 1,
    ),
    NumberWord(
      number: 4,
      word: 'Pip',
      audioFiles: ['4.Pip.wav'],
      level: 1,
    ),
    NumberWord(
      number: 5,
      word: 'Trattrø',
      audioFiles: ['5.Trattrø.wav'],
      level: 1,
    ),
    NumberWord(
      number: 6,
      word: 'Trattrø Kan',
      audioFiles: ['6.Trattrø_Kan.wav'],
      level: 1,
    ),
    NumberWord(
      number: 7,
      word: 'Trattrø Pa',
      audioFiles: ['7.Trattrø_Pa.wav'],
      level: 1,
    ),
    NumberWord(
      number: 8,
      word: 'Trattrø Pøn',
      audioFiles: ['8.Trattrø_Pøn.wav'],
      level: 1,
    ),
    NumberWord(
      number: 9,
      word: 'Trattrø Pip',
      audioFiles: ['9.Trattrø_Pip.wav'],
      level: 1,
    ),
    



    // Nivel 2: Números del 10 al 99
    NumberWord(
      number: 15,
      word: 'Kantsitrattrø',
      audioFiles: ['1.Kan.wav', 'Tsi.wav', '5.Trattrø.wav'],
      level: 2,
    ),
    NumberWord(
      number: 28,
      word: 'Patsitrattrøpøn',
      audioFiles: ['2.Pa.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav'],
      level: 2,
    ),
    NumberWord(
      number: 39,
      word: 'Pøntsi Trattrøpip',
      audioFiles: ['3.Pøn.wav', 'Tsi.wav', '9.Trattrø_Pip.wav'],
      level: 2,
    ),
    NumberWord(
      number: 42,
      word: 'Piptsi Pa',
      audioFiles: ['4.Pip.wav', 'Tsi.wav', '2.Pa.wav'],
      level: 2,
    ),
    NumberWord(
      number: 56,
      word: 'Trattrøtsi Trattrøkan',
      audioFiles: ['5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav'],
      level: 2,
    ),
    NumberWord(
      number: 61,
      word: 'Trattrøkantsi kan',
      audioFiles: ['6.Trattrø_Kan.wav', 'Tsi.wav', '1.Kan.wav'],
      level: 2,
    ),
    NumberWord(
      number: 74,
      word: 'Trattrøpatsi Pip',
      audioFiles: ['7.Trattrø_Pa.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 2,
    ),
    NumberWord(
      number: 87,
      word: 'Trattrøpøntsi Trattrøpa',
      audioFiles: ['8.Trattrø_Pøn.wav', 'Tsi.wav', '7.Trattrø_Pa.wav'],
      level: 2,
    ),
    NumberWord(
      number: 93,
      word: 'Trattrøpiptsi pøn',
      audioFiles: ['9.Trattrø_Pip.wav', 'Tsi.wav', '3.Pøn.wav'],
      level: 2,
    ),
    



    // Nivel 3: Números del 100 al 999
    NumberWord(
      number: 109,
      word: 'Kansrel Trattrøpip',
      audioFiles: ['1.Kan.wav', 'Srel.wav', '9.Trattrø_Pip.wav'],
      level: 3,
    ),
    NumberWord(
      number: 134,
      word: 'Kansrel Pøntsi Pip',
      audioFiles: ['1.Kan.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 3,
    ),
    NumberWord(
      number: 245,
      word: 'Pasrel Piptsi Trattrø',
      audioFiles: ['2.Pa.wav', 'Srel.wav', '4.Pip.wav', 'Tsi.wav', '5.Trattrø.wav'],
      level: 3,
    ),
    NumberWord(
      number: 276,
      word: 'Pasrel Trattrøpatsi Trattrøkan',
      audioFiles: ['2.Pa.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '6.Trattrø_Kan.wav'],
      level: 3,
    ),
    NumberWord(
      number: 351,
      word: 'Pønsrel Trattrøtsi kan',
      audioFiles: ['3.Pøn.wav', 'Srel.wav', '5.Trattrø.wav', 'Tsi.wav', '1.Kan.wav'],
      level: 3,
    ),
    NumberWord(
      number: 387,
      word: 'Pønsrel Trattrøpøntsi Trattrøpa',
      audioFiles: ['3.Pøn.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '7.Trattrø_Pa.wav'],
      level: 3,
    ),
    NumberWord(
      number: 412,
      word: 'Pipsrel Kantsipa',
      audioFiles: ['4.Pip.wav', 'Srel.wav', '1.Kan.wav', 'Tsi.wav', '2.Pa.wav'],
      level: 3,
    ),
    NumberWord(
      number: 467,
      word: 'Pipsrel Trattrøkantsi Trattrøpa',
      audioFiles: ['4.Pip.wav', 'Srel.wav', '6.Trattrø_Kan.wav', 'Tsi.wav', '7.Trattrø_Pa.wav'],
      level: 3,
    ),
    NumberWord(
      number: 543,
      word: 'Trattrøsrel Piptsi pøn',
      audioFiles: ['5.Trattrø.wav', 'Srel.wav', '4.Pip.wav', 'Tsi.wav', '3.Pøn.wav'],
      level: 3,
    ),
    NumberWord(
      number: 573,
      word: 'Trattrøsrel Trattrøpatsi pøn',
      audioFiles: ['5.Trattrø.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '3.Pøn.wav'],
      level: 3,
    ),
    NumberWord(
      number: 621,
      word: 'Trattrøkansrel Patsikan',
      audioFiles: ['6.Trattrø_Kan.wav', 'Srel.wav', '2.Pa.wav', 'Tsi.wav', '1.Kan.wav'],
      level: 3,
    ),
    NumberWord(
      number: 684,
      word: 'Trattrøkansrel Trattrøpøntsi Pip',
      audioFiles: ['6.Trattrø_Kan.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 3,
    ),
    NumberWord(
      number: 798,
      word: 'Trattrøpasrel Trattrøpiptsi Trattrøpøn',
      audioFiles: ['7.Trattrø_Pa.wav', 'Srel.wav', '9.Trattrø_Pip.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav'],
      level: 3,
    ),
    NumberWord(
      number: 809,
      word: 'Trattrøpønsrel Trattrøpip',
      audioFiles: ['8.Trattrø_Pøn.wav', 'Srel.wav', '9.Trattrø_Pip.wav'],
      level: 3,
    ),
    NumberWord(
      number: 872,
      word: 'Trattrøpønsrel Trattrøpatsi Pa',
      audioFiles: ['8.Trattrø_Pøn.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '2.Pa.wav'],
      level: 3,
    ),
    NumberWord(
      number: 927,
      word: 'Trattrøpipsrel Patsitrattrøpa',
      audioFiles: ['9.Trattrø_Pip.wav', 'Srel.wav', '2.Pa.wav', 'Tsi.wav', '7.Trattrø_Pa.wav'],
      level: 3,
    ),
    NumberWord(
      number: 956,
      word: 'Trattrøpipsrel Trattrøtsi Trattrøkan',
      audioFiles: ['9.Trattrø_Pip.wav', 'Srel.wav', '5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav'],
      level: 3,
    ),
    NumberWord(
      number: 991,
      word: 'Trattrøpipsrel Trattrøpiptsi kan',
      audioFiles: ['9.Trattrø_Pip.wav', 'Srel.wav', '9.Trattrø_Pip.wav', 'Tsi.wav', '1.Kan.wav'],
      level: 3,
    ),
    



    // Nivel 4: Números del 1000 al 9999
    NumberWord(
      number: 1123,
      word: 'Kanishik Kansrel Patsipøn',
      audioFiles: ['1.Kan.wav', 'Ishik.wav', '1.Kan.wav', 'Srel.wav', '2.Pa.wav', 'Tsi.wav', '3.Pøn.wav'],
      level: 4,
    ),
    NumberWord(
      number: 1478,
      word: 'Kanishik Pipsrel Trattrøpatsi Trattrøpøn',
      audioFiles: ['1.Kan.wav', 'Ishik.wav', '4.Pip.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav'],
      level: 4,
    ),
    NumberWord(
      number: 1892,
      word: 'Kanishik Trattrøpønsrel Trattrøpiptsi Pa',
      audioFiles: ['1.Kan.wav', 'Ishik.wav', '8.Trattrø_Pøn.wav', 'Srel.wav', '9.Trattrø_Pip.wav', 'Tsi.wav', '2.Pa.wav'],
      level: 4,
    ),
    NumberWord(
      number: 2345,
      word: 'Paishik Pønsrel Piptsi Trattrø',
      audioFiles: ['2.Pa.wav', 'Ishik.wav', '3.Pøn.wav', 'Srel.wav', '4.Pip.wav', 'Tsi.wav', '5.Trattrø.wav'],
      level: 4,
    ),
    NumberWord(
      number: 2671,
      word: 'Paishik Trattrøkansrel Trattrøpatsi kan',
      audioFiles: ['2.Pa.wav', 'Ishik.wav', '6.Trattrø_Kan.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '1.Kan.wav'],
      level: 4,
    ),
    NumberWord(
      number: 2987,
      word: 'Paishik Trattrøpipsrel Trattrøpøntsi Trattrøpa',
      audioFiles: ['2.Pa.wav', 'Ishik.wav', '9.Trattrø_Pip.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '7.Trattrø_Pa.wav'],
      level: 4,
    ),
    NumberWord(
      number: 3124,
      word: 'Pønishik Kansrel Patsipip',
      audioFiles: ['3.Pøn.wav', 'Ishik.wav', '1.Kan.wav', 'Srel.wav', '2.Pa.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 4,
    ),
    NumberWord(
      number: 3456,
      word: 'Pønishik Pipsrel Trattrøtsi Trattrøkan',
      audioFiles: ['3.Pøn.wav', 'Ishik.wav', '4.Pip.wav', 'Srel.wav', '5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav'],
      level: 4,
    ),
    NumberWord(
      number: 3789,
      word: 'Pønishik Trattrøpasrel Trattrøpøntsi Trattrøpip',
      audioFiles: ['3.Pøn.wav', 'Ishik.wav', '7.Trattrø_Pa.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '9.Trattrø_Pip.wav'],
      level: 4,
    ),
    NumberWord(
      number: 4123,
      word: 'Pipishik Kansrel Patsipøn',
      audioFiles: ['4.Pip.wav', 'Ishik.wav', '1.Kan.wav', 'Srel.wav', '2.Pa.wav', 'Tsi.wav', '3.Pøn.wav'],
      level: 4,
    ),
    NumberWord(
      number: 4567,
      word: 'Pipishik Trattrøsrel Trattrøkantsi Trattrøpa',
      audioFiles: ['4.Pip.wav', 'Ishik.wav', '5.Trattrø.wav', 'Srel.wav', '6.Trattrø_Kan.wav', 'Tsi.wav', '7.Trattrø_Pa.wav'],
      level: 4,
    ),
    NumberWord(
      number: 4891,
      word: 'Pipishik Trattrøpønsrel Trattrøpiptsi kan',
      audioFiles: ['4.Pip.wav', 'Ishik.wav', '8.Trattrø_Pøn.wav', 'Srel.wav', '9.Trattrø_Pip.wav', 'Tsi.wav', '1.Kan.wav'],
      level: 4,
    ),
    NumberWord(
      number: 5234,
      word: 'Trattrøishik Pasrel Pøntsi Pip',
      audioFiles: ['5.Trattrø.wav', 'Ishik.wav', '2.Pa.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 4,
    ),
    NumberWord(
      number: 5678,
      word: 'Trattrøishik Trattrøkansrel Trattrøpatsi Trattrøpøn',
      audioFiles: ['5.Trattrø.wav', 'Ishik.wav', '6.Trattrø_Kan.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav'],
      level: 4,
    ),
    NumberWord(
      number: 5982,
      word: 'Trattrøishik Trattrøpipsrel Trattrøpøntsi Pa',
      audioFiles: ['5.Trattrø.wav', 'Ishik.wav', '9.Trattrø_Pip.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '2.Pa.wav'],
      level: 4,
    ),
    NumberWord(
      number: 6231,
      word: 'Trattrøkanishik Pasrel Pøntsi kan',
      audioFiles: ['6.Trattrø_Kan.wav', 'Ishik.wav', '2.Pa.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '1.Kan.wav'],
      level: 4,
    ),
    NumberWord(
      number: 6574,
      word: 'Trattrøkanishik Trattrøsrel Trattrøpatsi Pip',
      audioFiles: ['6.Trattrø_Kan.wav', 'Ishik.wav', '5.Trattrø.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 4,
    ),
    NumberWord(
      number: 6890,
      word: 'Trattrøkanishik Trattrøpønsrel Trattrøpiptsi',
      audioFiles: ['6.Trattrø_Kan.wav', 'Ishik.wav', '8.Trattrø_Pøn.wav', 'Srel.wav', '9.Trattrø_Pip.wav', 'Tsi.wav'],
      level: 4,
    ),
    NumberWord(
      number: 7123,
      word: 'Trattrøpaishik Kansrel Patsipøn',
      audioFiles: ['7.Trattrø_Pa.wav', 'Ishik.wav', '1.Kan.wav', 'Srel.wav', '2.Pa.wav', 'Tsi.wav', '3.Pøn.wav'],
      level: 4,
    ),
    NumberWord(
      number: 7456,
      word: 'Trattrøpaishik Pipsrel Trattrøtsi Trattrøkan',
      audioFiles: ['7.Trattrø_Pa.wav', 'Ishik.wav', '4.Pip.wav', 'Srel.wav', '5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav'],
      level: 4,
    ),
    NumberWord(
      number: 7892,
      word: 'Trattrøpaishik Trattrøpønsrel Trattrøpiptsi Pa',
      audioFiles: ['7.Trattrø_Pa.wav', 'Ishik.wav', '8.Trattrø_Pøn.wav', 'Srel.wav', '9.Trattrø_Pip.wav', 'Tsi.wav', '2.Pa.wav'],
      level: 4,
    ),
    NumberWord(
      number: 8234,
      word: 'Trattrøpønishik Pasrel Pøntsi Pip',
      audioFiles: ['8.Trattrø_Pøn.wav', 'Ishik.wav', '2.Pa.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 4,
    ),
    NumberWord(
      number: 8567,
      word: 'Trattrøpønishik Trattrøsrel Trattrøkantsi Trattrøpa',
      audioFiles: ['8.Trattrø_Pøn.wav', 'Ishik.wav', '5.Trattrø.wav', 'Srel.wav', '6.Trattrø_Kan.wav', 'Tsi.wav', '7.Trattrø_Pa.wav'],
      level: 4,
    ),
    NumberWord(
      number: 8912,
      word: 'Trattrøpønishik Trattrøpipsrel Kantsipa',
      audioFiles: ['8.Trattrø_Pøn.wav', 'Ishik.wav', '9.Trattrø_Pip.wav', 'Srel.wav', '1.Kan.wav', 'Tsi.wav', '2.Pa.wav'],
      level: 4,
    ),
    NumberWord(
      number: 9234,
      word: 'Trattrøpipishik Pasrel Pøntsi Pip',
      audioFiles: ['9.Trattrø_Pip.wav', 'Ishik.wav', '2.Pa.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 4,
    ),
    NumberWord(
      number: 9567,
      word: 'Trattrøpipishik Trattrøsrel Trattrøkantsi Trattrøpa',
      audioFiles: ['9.Trattrø_Pip.wav', 'Ishik.wav', '5.Trattrø.wav', 'Srel.wav', '6.Trattrø_Kan.wav', 'Tsi.wav', '7.Trattrø_Pa.wav'],
      level: 4,
    ),
    NumberWord(
      number: 9876,
      word: 'Trattrøpipishik Trattrøpønsrel Trattrøpatsi Trattrøkan',
      audioFiles: ['9.Trattrø_Pip.wav', 'Ishik.wav', '8.Trattrø_Pøn.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '6.Trattrø_Kan.wav'],
      level: 4,
    ),
    

    

    // Nivel 5: Números del 10000 al 99999
    NumberWord(
      number: 10345,
      word: 'Kantsiishik Pønsrel Piptsi Trattrø',
      audioFiles: ['1.Kan.wav', 'Tsi.wav', 'Ishik.wav', '3.Pøn.wav', 'Srel.wav', '4.Pip.wav', 'Tsi.wav', '5.Trattrø.wav'],
      level: 5,
    ),
    NumberWord(
      number: 12891,
      word: 'Kantsipaishik Trattrøpønsrel Trattrøpiptsi kan',
      audioFiles: ['1.Kan.wav', 'Tsi.wav', '2.Pa.wav', 'Ishik.wav', '8.Trattrø_Pøn.wav', 'Srel.wav', '9.Trattrø_Pip.wav', 'Tsi.wav', '1.Kan.wav'],
      level: 5,
    ),
    NumberWord(
      number: 15432,
      word: 'Kantsitrattrøishik Pipsrel Pøntsi Pa',
      audioFiles: ['1.Kan.wav', 'Tsi.wav', '5.Trattrø.wav', 'Ishik.wav', '4.Pip.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '2.Pa.wav'],
      level: 5,
    ),
    NumberWord(
      number: 18765,
      word: 'Kantsitrattrøpønishik Trattrøpasrel Trattrøkantsi Trattrø',
      audioFiles: ['1.Kan.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav', 'Ishik.wav', '7.Trattrø_Pa.wav', 'Srel.wav', '6.Trattrø_Kan.wav', 'Tsi.wav', '5.Trattrø.wav'],
      level: 5,
    ),
    NumberWord(
      number: 21378,
      word: 'Patsikanishik Pønsrel Trattrøpatsi Trattrøpøn',
      audioFiles: ['2.Pa.wav', 'Tsi.wav', '1.Kan.wav', 'Ishik.wav', '3.Pøn.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav'],
      level: 5,
    ),
    NumberWord(
      number: 24591,
      word: 'Patsipipishik Trattrøsrel Trattrøpiptsi kan',
      audioFiles: ['2.Pa.wav', 'Tsi.wav', '4.Pip.wav', 'Ishik.wav', '5.Trattrø.wav', 'Srel.wav', '9.Trattrø_Pip.wav', 'Tsi.wav', '1.Kan.wav'],
      level: 5,
    ),
    NumberWord(
      number: 26734,
      word: 'Patsitrattrøkanishik Trattrøpasrel Pøntsi Pip',
      audioFiles: ['2.Pa.wav', 'Tsi.wav', '6.Trattrø_Kan.wav', 'Ishik.wav', '7.Trattrø_Pa.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 5,
    ),
    NumberWord(
      number: 28912,
      word: 'Patsitrattrøpønishik Trattrøpipsrel Kantsipa',
      audioFiles: ['2.Pa.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav', 'Ishik.wav', '9.Trattrø_Pip.wav', 'Srel.wav', '1.Kan.wav', 'Tsi.wav', '2.Pa.wav'],
      level: 5,
    ),
    NumberWord(
      number: 31256,
      word: 'Pøntsi kanishik Pasrel Trattrøtsi Trattrøkan',
      audioFiles: ['3.Pøn.wav', 'Tsi.wav', '1.Kan.wav', 'Ishik.wav', '2.Pa.wav', 'Srel.wav', '5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav'],
      level: 5,
    ),
    NumberWord(
      number: 34589,
      word: 'Pøntsi Pipishik Trattrøsrel Trattrøpøntsi Trattrøpip',
      audioFiles: ['3.Pøn.wav', 'Tsi.wav', '4.Pip.wav', 'Ishik.wav', '5.Trattrø.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '9.Trattrø_Pip.wav'],
      level: 5,
    ),
    NumberWord(
      number: 37812,
      word: 'Pøntsi Trattrøpaishik Trattrøpønsrel Kantsipa',
      audioFiles: ['3.Pøn.wav', 'Tsi.wav', '7.Trattrø_Pa.wav', 'Ishik.wav', '8.Trattrø_Pøn.wav', 'Srel.wav', '1.Kan.wav', 'Tsi.wav', '2.Pa.wav'],
      level: 5,
    ),
    NumberWord(
      number: 40123,
      word: 'Piptsiishik Kansrel Patsipøn',
      audioFiles: ['4.Pip.wav', 'Tsi.wav', 'Ishik.wav', '1.Kan.wav', 'Srel.wav', '2.Pa.wav', 'Tsi.wav', '3.Pøn.wav'],
      level: 5,
    ),
    NumberWord(
      number: 43256,
      word: 'Piptsi pønishik Pasrel Trattrøtsi Trattrøkan',
      audioFiles: ['4.Pip.wav', 'Tsi.wav', '3.Pøn.wav', 'Ishik.wav', '2.Pa.wav', 'Srel.wav', '5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav'],
      level: 5,
    ),
    NumberWord(
      number: 46578,
      word: 'Piptsi Trattrøkanishik Trattrøsrel Trattrøpatsi Trattrøpøn',
      audioFiles: ['4.Pip.wav', 'Tsi.wav', '6.Trattrø_Kan.wav', 'Ishik.wav', '5.Trattrø.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav'],
      level: 5,
    ),
    NumberWord(
      number: 48791,
      word: 'Piptsi Trattrøpønishik Trattrøpasrel Trattrøpiptsi kan',
      audioFiles: ['4.Pip.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav', 'Ishik.wav', '7.Trattrø_Pa.wav', 'Srel.wav', '9.Trattrø_Pip.wav', 'Tsi.wav', '1.Kan.wav'],
      level: 5,
    ),
    NumberWord(
      number: 51234,
      word: 'Trattrøtsi kanishik Pasrel Pøntsi Pip',
      audioFiles: ['5.Trattrø.wav', 'Tsi.wav', '1.Kan.wav', 'Ishik.wav', '2.Pa.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 5,
    ),
    NumberWord(
      number: 53467,
      word: 'Trattrøtsi pønishik Pipsrel Trattrøkantsi Trattrøpa',
      audioFiles: ['5.Trattrø.wav', 'Tsi.wav', '3.Pøn.wav', 'Ishik.wav', '4.Pip.wav', 'Srel.wav', '6.Trattrø_Kan.wav', 'Tsi.wav', '7.Trattrø_Pa.wav'],
      level: 5,
    ),
    NumberWord(
      number: 56712,
      word: 'Trattrøtsi Trattrøkanishik Trattrøpasrel Kantsipa',
      audioFiles: ['5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav', 'Ishik.wav', '7.Trattrø_Pa.wav', 'Srel.wav', '1.Kan.wav', 'Tsi.wav', '2.Pa.wav'],
      level: 5,
    ),
    NumberWord(
      number: 58934,
      word: 'Trattrøtsi Trattrøpønishik Trattrøpipsrel Pøntsi Pip',
      audioFiles: ['5.Trattrø.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav', 'Ishik.wav', '9.Trattrø_Pip.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 5,
    ),
    NumberWord(
      number: 61278,
      word: 'Trattrøkantsi kanishik Pasrel Trattrøpatsi Trattrøpøn',
      audioFiles: ['6.Trattrø_Kan.wav', 'Tsi.wav', '1.Kan.wav', 'Ishik.wav', '2.Pa.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav'],
      level: 5,
    ),
    NumberWord(
      number: 64523,
      word: 'Trattrøkantsi Pipishik Trattrøsrel Patsipøn',
      audioFiles: ['6.Trattrø_Kan.wav', 'Tsi.wav', '4.Pip.wav', 'Ishik.wav', '5.Trattrø.wav', 'Srel.wav', '2.Pa.wav', 'Tsi.wav', '3.Pøn.wav'],
      level: 5,
    ),
    NumberWord(
      number: 67891,
      word: 'Trattrøkantsi Trattrøpaishik Trattrøpønsrel Trattrøpiptsi kan',
      audioFiles: ['6.Trattrø_Kan.wav', 'Tsi.wav', '7.Trattrø_Pa.wav', 'Ishik.wav', '8.Trattrø_Pøn.wav', 'Srel.wav', '9.Trattrø_Pip.wav', 'Tsi.wav', '1.Kan.wav'],
      level: 5,
    ),
    NumberWord(
      number: 70123,
      word: 'Trattrøpatsiishik Kansrel Patsipøn',
      audioFiles: ['7.Trattrø_Pa.wav', 'Tsi.wav', 'Ishik.wav', '1.Kan.wav', 'Srel.wav', '2.Pa.wav', 'Tsi.wav', '3.Pøn.wav'],
      level: 5,
    ),
    NumberWord(
      number: 73456,
      word: 'Trattrøpatsi pønishik Pipsrel Trattrøtsi Trattrøkan',
      audioFiles: ['7.Trattrø_Pa.wav', 'Tsi.wav', '3.Pøn.wav', 'Ishik.wav', '4.Pip.wav', 'Srel.wav', '5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav'],
      level: 5,
    ),
    NumberWord(
      number: 76589,
      word: 'Trattrøpatsi Trattrøkanishik Trattrøsrel Trattrøpøntsi Trattrøpip',
      audioFiles: ['7.Trattrø_Pa.wav', 'Tsi.wav', '6.Trattrø_Kan.wav', 'Ishik.wav', '5.Trattrø.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '9.Trattrø_Pip.wav'],
      level: 5,
    ),
    NumberWord(
      number: 81234,
      word: 'Trattrøpøntsi kanishik Pasrel Pøntsi Pip',
      audioFiles: ['8.Trattrø_Pøn.wav', 'Tsi.wav', '1.Kan.wav', 'Ishik.wav', '2.Pa.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 5,
    ),
    NumberWord(
      number: 94567,
      word: 'Trattrøpiptsi Pipishik Trattrøsrel Trattrøkantsi Trattrøpa',
      audioFiles: ['9.Trattrø_Pip.wav', 'Tsi.wav', '4.Pip.wav', 'Ishik.wav', '5.Trattrø.wav', 'Srel.wav', '6.Trattrø_Kan.wav', 'Tsi.wav', '7.Trattrø_Pa.wav'],
      level: 5,
    ),
    
    
    
    
    // Nivel 6: Números del 100000 al 999999
    NumberWord(
      number: 112345,
      word: 'Kansrel Kantsipaishik Pønsrel Piptsi Trattrø',
      audioFiles: ['1.Kan.wav', 'Srel.wav', '1.Kan.wav', 'Tsi.wav', '2.Pa.wav', 'Ishik.wav', '3.Pøn.wav', 'Srel.wav', '4.Pip.wav', 'Tsi.wav', '5.Trattrø.wav'],
      level: 6,
    ),
    NumberWord(
      number: 134678,
      word: 'Kansrel Pøntsi Pipishik Trattrøkansrel Trattrøpatsi Trattrøpøn',
      audioFiles: ['1.Kan.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '4.Pip.wav', 'Ishik.wav', '6.Trattrø_Kan.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav'],
      level: 6,
    ),
    NumberWord(
      number: 156789,
      word: 'Kansrel Trattrøtsi Trattrøkanishik Trattrøpasrel Trattrøpøntsi Trattrøpip',
      audioFiles: ['1.Kan.wav', 'Srel.wav', '5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav', 'Ishik.wav', '7.Trattrø_Pa.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '9.Trattrø_Pip.wav'],
      level: 6,
    ),
    NumberWord(
      number: 189234,
      word: 'Kansrel Trattrøpøntsi Trattrøpipishik Pasrel Pøntsi Pip',
      audioFiles: ['1.Kan.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '9.Trattrø_Pip.wav', 'Ishik.wav', '2.Pa.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 6,
    ),
    NumberWord(
      number: 213456,
      word: 'Pasrel Kantsipønishik Pipsrel Trattrøtsi Trattrøkan',
      audioFiles: ['2.Pa.wav', 'Srel.wav', '1.Kan.wav', 'Tsi.wav', '3.Pøn.wav', 'Ishik.wav', '4.Pip.wav', 'Srel.wav', '5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav'],
      level: 6,
    ),
    NumberWord(
      number: 245789,
      word: 'Pasrel Piptsi Trattrøishik Trattrøpasrel Trattrøpøntsi Trattrøpip',
      audioFiles: ['2.Pa.wav', 'Srel.wav', '4.Pip.wav', 'Tsi.wav', '5.Trattrø.wav', 'Ishik.wav', '7.Trattrø_Pa.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '9.Trattrø_Pip.wav'],
      level: 6,
    ),
    NumberWord(
      number: 267123,
      word: 'Pasrel Trattrøkantsi Trattrøpaishik Kansrel Patsipøn',
      audioFiles: ['2.Pa.wav', 'Srel.wav', '6.Trattrø_Kan.wav', 'Tsi.wav', '7.Trattrø_Pa.wav', 'Ishik.wav', '1.Kan.wav', 'Srel.wav', '2.Pa.wav', 'Tsi.wav', '3.Pøn.wav'],
      level: 6,
    ),
    NumberWord(
      number: 289456,
      word: 'Pasrel Trattrøpøntsi Trattrøpipishik Pipsrel Trattrøtsi Trattrøkan',
      audioFiles: ['2.Pa.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '9.Trattrø_Pip.wav', 'Ishik.wav', '4.Pip.wav', 'Srel.wav', '5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav'],
      level: 6,
    ),
    NumberWord(
      number: 312678,
      word: 'Pønsrel Kantsipaishik Trattrøkansrel Trattrøpatsi Trattrøpøn',
      audioFiles: ['3.Pøn.wav', 'Srel.wav', '1.Kan.wav', 'Tsi.wav', '2.Pa.wav', 'Ishik.wav', '6.Trattrø_Kan.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav'],
      level: 6,
    ),
    NumberWord(
      number: 345912,
      word: 'Pønsrel Piptsi Trattrøishik Trattrøpipsrel Kantsipa',
      audioFiles: ['3.Pøn.wav', 'Srel.wav', '4.Pip.wav', 'Tsi.wav', '5.Trattrø.wav', 'Ishik.wav', '9.Trattrø_Pip.wav', 'Srel.wav', '1.Kan.wav', 'Tsi.wav', '2.Pa.wav'],
      level: 6,
    ),
    NumberWord(
      number: 367234,
      word: 'Pønsrel Trattrøkantsi Trattrøpaishik Pasrel Pøntsi Pip',
      audioFiles: ['3.Pøn.wav', 'Srel.wav', '6.Trattrø_Kan.wav', 'Tsi.wav', '7.Trattrø_Pa.wav', 'Ishik.wav', '2.Pa.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 6,
    ),
    NumberWord(
      number: 389567,
      word: 'Pønsrel Trattrøpøntsi Trattrøpipishik Trattrøsrel Trattrøkantsi Trattrøpa',
      audioFiles: ['3.Pøn.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '9.Trattrø_Pip.wav', 'Ishik.wav', '5.Trattrø.wav', 'Srel.wav', '6.Trattrø_Kan.wav', 'Tsi.wav', '7.Trattrø_Pa.wav'],
      level: 6,
    ),
    NumberWord(
      number: 412345,
      word: 'Pipsrel Kantsipaishik Pønsrel Piptsi Trattrø',
      audioFiles: ['4.Pip.wav', 'Srel.wav', '1.Kan.wav', 'Tsi.wav', '2.Pa.wav', 'Ishik.wav', '3.Pøn.wav', 'Srel.wav', '4.Pip.wav', 'Tsi.wav', '5.Trattrø.wav'],
      level: 6,
    ),
    NumberWord(
      number: 435678,
      word: 'Pipsrel Pøntsi Trattrøishik Trattrøkansrel Trattrøpatsi Trattrøpøn',
      audioFiles: ['4.Pip.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '5.Trattrø.wav', 'Ishik.wav', '6.Trattrø_Kan.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav'],
      level: 6,
    ),
    NumberWord(
      number: 456789,
      word: 'Pipsrel Trattrøtsi Trattrøkanishik Trattrøpasrel Trattrøpøntsi Trattrøpip',
      audioFiles: ['4.Pip.wav', 'Srel.wav', '5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav', 'Ishik.wav', '7.Trattrø_Pa.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '9.Trattrø_Pip.wav'],
      level: 6,
    ),
    NumberWord(
      number: 478123,
      word: 'Pipsrel Trattrøpatsi Trattrøpønishik Kansrel Patsipøn',
      audioFiles: ['4.Pip.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav', 'Ishik.wav', '1.Kan.wav', 'Srel.wav', '2.Pa.wav', 'Tsi.wav', '3.Pøn.wav'],
      level: 6,
    ),
    NumberWord(
      number: 501234,
      word: 'Trattrøsrel kanishik Pasrel Pøntsi Pip',
      audioFiles: ['5.Trattrø.wav', 'Srel.wav', '1.Kan.wav', 'Ishik.wav', '2.Pa.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 6,
    ),
    NumberWord(
      number: 523456,
      word: 'Trattrøsrel Patsipønishik Pipsrel Trattrøtsi Trattrøkan',
      audioFiles: ['5.Trattrø.wav', 'Srel.wav', '2.Pa.wav', 'Tsi.wav', '3.Pøn.wav', 'Ishik.wav', '4.Pip.wav', 'Srel.wav', '5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav'],
      level: 6,
    ),
    NumberWord(
      number: 545789,
      word: 'Trattrøsrel Piptsi Trattrøishik Trattrøpasrel Trattrøpøntsi Trattrøpip',
      audioFiles: ['5.Trattrø.wav', 'Srel.wav', '4.Pip.wav', 'Tsi.wav', '5.Trattrø.wav', 'Ishik.wav', '7.Trattrø_Pa.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '9.Trattrø_Pip.wav'],
      level: 6,
    ),
    NumberWord(
      number: 567123,
      word: 'Trattrøsrel Trattrøkantsi Trattrøpaishik Kansrel Patsipøn',
      audioFiles: ['5.Trattrø.wav', 'Srel.wav', '6.Trattrø_Kan.wav', 'Tsi.wav', '7.Trattrø_Pa.wav', 'Ishik.wav', '1.Kan.wav', 'Srel.wav', '2.Pa.wav', 'Tsi.wav', '3.Pøn.wav'],
      level: 6,
    ),
    NumberWord(
      number: 589456,
      word: 'Trattrøsrel Trattrøpøntsi Trattrøpipishik Pipsrel Trattrøtsi Trattrøkan',
      audioFiles: ['5.Trattrø.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '9.Trattrø_Pip.wav', 'Ishik.wav', '4.Pip.wav', 'Srel.wav', '5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav'],
      level: 6,
    ),
    NumberWord(
      number: 612789,
      word: 'Trattrøkansrel Kantsipaishik Trattrøpasrel Trattrøpøntsi Trattrøpip',
      audioFiles: ['6.Trattrø_Kan.wav', 'Srel.wav', '1.Kan.wav', 'Tsi.wav', '2.Pa.wav', 'Ishik.wav', '7.Trattrø_Pa.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '9.Trattrø_Pip.wav'],
      level: 6,
    ),
    NumberWord(
      number: 645123,
      word: 'Trattrøkansrel Piptsi Trattrøishik Kansrel Patsipøn',
      audioFiles: ['6.Trattrø_Kan.wav', 'Srel.wav', '4.Pip.wav', 'Tsi.wav', '5.Trattrø.wav', 'Ishik.wav', '1.Kan.wav', 'Srel.wav', '2.Pa.wav', 'Tsi.wav', '3.Pøn.wav'],
      level: 6,
    ),
    NumberWord(
      number: 678234,
      word: 'Trattrøkansrel Trattrøpatsi Trattrøpønishik Pasrel Pøntsi Pip',
      audioFiles: ['6.Trattrø_Kan.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav', 'Ishik.wav', '2.Pa.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '4.Pip.wav'],
      level: 6,
    ),
    NumberWord(
      number: 701456,
      word: 'Trattrøpasrel kanishik Pipsrel Trattrøtsi Trattrøkan',
      audioFiles: ['7.Trattrø_Pa.wav', 'Srel.wav', '1.Kan.wav', 'Ishik.wav', '4.Pip.wav', 'Srel.wav', '5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav'],
      level: 6,
    ),
    NumberWord(
      number: 734589,
      word: 'Trattrøpasrel Pøntsi Pipishik Trattrøsrel Trattrøpøntsi Trattrøpip',
      audioFiles: ['7.Trattrø_Pa.wav', 'Srel.wav', '3.Pøn.wav', 'Tsi.wav', '4.Pip.wav', 'Ishik.wav', '5.Trattrø.wav', 'Srel.wav', '8.Trattrø_Pøn.wav', 'Tsi.wav', '9.Trattrø_Pip.wav'],
      level: 6,
    ),
    NumberWord(
      number: 845678,
      word: 'Trattrøpønsrel Piptsi Trattrøishik Trattrøkansrel Trattrøpatsi Trattrøpøn',
      audioFiles: ['8.Trattrø_Pøn.wav', 'Srel.wav', '4.Pip.wav', 'Tsi.wav', '5.Trattrø.wav', 'Ishik.wav', '6.Trattrø_Kan.wav', 'Srel.wav', '7.Trattrø_Pa.wav', 'Tsi.wav', '8.Trattrø_Pøn.wav'],
      level: 6,
    ),
    NumberWord(
      number: 956123,
      word: 'Trattrøpipsrel Trattrøtsi Trattrøkanishik Kansrel Patsipøn',
      audioFiles: ['9.Trattrø_Pip.wav', 'Srel.wav', '5.Trattrø.wav', 'Tsi.wav', '6.Trattrø_Kan.wav', 'Ishik.wav', '1.Kan.wav', 'Srel.wav', '2.Pa.wav', 'Tsi.wav', '3.Pøn.wav'],
      level: 6,
    ),
  ];

  static NumberWord? getRandomNumber({required int level}) {
    try {
      final levelNumbers = numbers.where((n) => n.level == level).toList();
      if (levelNumbers.isEmpty) {
        debugPrint('No hay números disponibles para el nivel $level');
        return null;
      }
      return levelNumbers[Random().nextInt(levelNumbers.length)];
    } catch (e) {
      debugPrint('Error en getRandomNumber: $e');
      return null;
    }
  }

  static List<int> generateOptionsForLevel2(int correctNumber) {
    final random = Random();
    final Set<int> options = {correctNumber};
    
    try {
      // Obtener todos los números del nivel 2
      final level2Numbers = numbers
          .where((n) => n.level == 2)
          .map((n) => n.number)
          .toList();

      if (level2Numbers.isNotEmpty) {
        // Mezclar los números disponibles
        level2Numbers.shuffle(random);

        // Agregar números únicos hasta tener 4 opciones
        for (final number in level2Numbers) {
          if (number != correctNumber) {
            options.add(number);
          }
          if (options.length >= 4) break;
        }
      }

      // Si no hay suficientes números predefinidos, generar aleatorios
      while (options.length < 4) {
        final randomNumber = random.nextInt(90) + 10;
        options.add(randomNumber);
      }

      final result = options.toList();
      result.shuffle(random);
      return result;
    } catch (e) {
      debugPrint('Error en generateOptionsForLevel2: $e');
      // En caso de error, devolver opciones básicas
      return [correctNumber, correctNumber + 1, correctNumber + 2, correctNumber + 3];
    }
  }

  static List<int> generateOptionsForLevel3(int correctNumber) {
    final random = Random();
    final Set<int> options = {correctNumber};
    
    try {
      // Obtener todos los números del nivel 3
      final level3Numbers = numbers
          .where((n) => n.level == 3)
          .map((n) => n.number)
          .toList();

      if (level3Numbers.isNotEmpty) {
        // Mezclar los números disponibles
        level3Numbers.shuffle(random);

        // Agregar números únicos hasta tener 4 opciones
        for (final number in level3Numbers) {
          if (number != correctNumber) {
            options.add(number);
          }
          if (options.length >= 4) break;
        }
      }

      // Si no hay suficientes números predefinidos, generar aleatorios
      while (options.length < 4) {
        // Generar números aleatorios entre 100 y 999
        final randomNumber = random.nextInt(900) + 100;
        if (!options.contains(randomNumber)) {
          options.add(randomNumber);
        }
      }

      final result = options.toList();
      result.shuffle(random);
      return result;
    } catch (e) {
      debugPrint('Error en generateOptionsForLevel3: $e');
      // En caso de error, devolver opciones básicas manteniendo el rango 100-999
      return [correctNumber, 
              ((correctNumber + 100) % 900) + 100,
              ((correctNumber + 200) % 900) + 100,
              ((correctNumber + 300) % 900) + 100];
    }
  }

  static List<int> generateOptionsForLevel4(int correctNumber) {
    final random = Random();
    final Set<int> options = {correctNumber};
    
    try {
      // Obtener todos los números del nivel 4
      final level4Numbers = numbers
          .where((n) => n.level == 4)
          .map((n) => n.number)
          .toList();

      if (level4Numbers.isNotEmpty) {
        // Mezclar los números disponibles
        level4Numbers.shuffle(random);

        // Agregar números únicos hasta tener 4 opciones
        for (final number in level4Numbers) {
          if (number != correctNumber) {
            options.add(number);
          }
          if (options.length >= 4) break;
        }
      }

      // Si no hay suficientes números predefinidos, generar aleatorios
      while (options.length < 4) {
        // Generar números aleatorios entre 1000 y 9999
        final randomNumber = random.nextInt(9000) + 1000;
        if (!options.contains(randomNumber)) {
          options.add(randomNumber);
        }
      }

      final result = options.toList();
      result.shuffle(random);
      return result;
    } catch (e) {
      debugPrint('Error en generateOptionsForLevel4: $e');
      // En caso de error, devolver opciones básicas manteniendo el rango 1000-9999
      return [correctNumber, 
              ((correctNumber + 1000) % 9000) + 1000,
              ((correctNumber + 2000) % 9000) + 1000,
              ((correctNumber + 3000) % 9000) + 1000];
    }
  }

  static List<int> generateOptionsForLevel5(int correctNumber) {
    final random = Random();
    final Set<int> options = {correctNumber};
    
    try {
      // Obtener todos los números del nivel 5
      final level5Numbers = numbers
          .where((n) => n.level == 5)
          .map((n) => n.number)
          .toList();

      if (level5Numbers.isNotEmpty) {
        // Mezclar los números disponibles
        level5Numbers.shuffle(random);

        // Agregar números únicos hasta tener 4 opciones
        for (final number in level5Numbers) {
          if (number != correctNumber) {
            options.add(number);
          }
          if (options.length >= 4) break;
        }
      }

      // Si no hay suficientes números predefinidos, generar aleatorios
      while (options.length < 4) {
        // Generar números aleatorios entre 10000 y 99999
        final randomNumber = random.nextInt(90000) + 10000;
        if (!options.contains(randomNumber)) {
          options.add(randomNumber);
        }
      }

      final result = options.toList();
      result.shuffle(random);
      return result;
    } catch (e) {
      debugPrint('Error en generateOptionsForLevel5: $e');
      // En caso de error, devolver opciones básicas manteniendo el rango 10000-99999
      return [correctNumber, 
              ((correctNumber + 10000) % 90000) + 10000,
              ((correctNumber + 20000) % 90000) + 10000,
              ((correctNumber + 30000) % 90000) + 10000];
    }
  }

  static List<int> generateOptionsForLevel6(int correctNumber) {
    final random = Random();
    final Set<int> options = {correctNumber};
    
    try {
      // Obtener todos los números del nivel 6
      final level6Numbers = numbers
          .where((n) => n.level == 6)
          .map((n) => n.number)
          .toList();

      if (level6Numbers.isNotEmpty) {
        // Mezclar los números disponibles
        level6Numbers.shuffle(random);

        // Agregar números únicos hasta tener 4 opciones
        for (final number in level6Numbers) {
          if (number != correctNumber) {
            options.add(number);
          }
          if (options.length >= 4) break;
        }
      }

      // Si no hay suficientes números predefinidos, generar aleatorios
      while (options.length < 4) {
        // Generar números aleatorios entre 100000 y 999999
        final randomNumber = random.nextInt(900000) + 100000;
        if (!options.contains(randomNumber)) {
          options.add(randomNumber);
        }
      }

      final result = options.toList();
      result.shuffle(random);
      return result;
    } catch (e) {
      debugPrint('Error en generateOptionsForLevel6: $e');
      // En caso de error, devolver opciones básicas manteniendo el rango 100000-999999
      return [correctNumber, 
              ((correctNumber + 100000) % 900000) + 100000,
              ((correctNumber + 200000) % 900000) + 100000,
              ((correctNumber + 300000) % 900000) + 100000];
    }
  }
}