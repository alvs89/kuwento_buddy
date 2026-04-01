import 'package:kuwentobuddy/models/story_model.dart';
import 'package:kuwentobuddy/models/question_model.dart';

final List<StoryModel> filipinoTalesData = [
  // STORY 1 - BEGINNER
  StoryModel(
    id: 'alamat-ng-pinya',
    title: 'Ang Alamat ng Pinya (Inang Mahalaga)',
    author: 'Traditional Filipino Folktale',
    coverImage: 'assets/images/alamat_ng_pinya_cover_photo.jpg', // Placeholder
    description:
        'Isang kuwento tungkol sa batang si Pinya na hindi marunong makinig sa kanyang ina. Sa kanyang karanasan, matututuhan ang kahalagahan ng pagsunod, sipag, at pagmamahal sa magulang.',
    localizedTitles: {
      'en': 'The Legend of Pineapple (Mother Matters)',
    },
    level: StoryLevel.beginner,
    categories: [StoryCategory.filipinoTales],
    estimatedMinutes: 5,
    language: 'fil',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    sequenceActivity: [
      'Si Pinya ay isang batang hindi tumutulong at madalas maging tamad sa kanilang bahay.',
      'Inutusan siya ng kanyang ina na kumuha ng sandok sa kusina.',
      'Hindi niya nakita ang sandok kahit ito ay nasa harapan lamang niya.',
      'Nagalit at nasabi ng ina ang mga salitang hindi niya sinasadya.',
      'Sa huli, naging isang pinya si Pinya bilang bunga ng nangyari.',
    ],
    segments: [
      StorySegment(
        id: 'pinya-opening',
        content:
            'Page 1 (Opening Page)\nTitle: Ang Alamat ng Pinya (Inang Mahalaga)\nGenre: Filipino Tale\nLevel: Beginner\nLanguage: Filipino\nSynopsis:\nIsang kuwento tungkol sa batang si Pinya na hindi marunong makinig sa kanyang ina. Sa kanyang karanasan, matututuhan ang kahalagahan ng pagsunod, sipag, at pagmamahal sa magulang.\nSource / Reference:\nTraditional Filipino Folktale – Public Domain\nAdapted for KuwentoBuddy\nHeads Up:\nAng kuwento ay may checkpoint questions sa bawat bahagi.\n\nBasahin nang mabuti at pag-isipan ang bawat pangyayari bago magpatuloy.\n\nPinakamainam para sa gabay na panimulang pagkatuto',
      ),
      StorySegment(
        id: 'pinya-1',
        content:
            'Sa isang maliit at tahimik na baryo, may mag-inang nakatira sa isang simpleng kubo na gawa sa kahoy. Ang ina ay kilala sa kanilang lugar bilang isang masipag at mapagmahal na magulang na hindi napapagod sa pag-aasikaso sa kanilang tahanan. Araw-araw, maaga siyang gumigising upang magluto ng pagkain, maglinis ng bahay, at siguraduhing maayos ang lahat para sa kanilang araw.\n\nSamantala, ang kanyang anak na si Pinya ay isang batang maganda ngunit tamad at hindi palatulong sa gawaing-bahay. Kadalasan, makikita siyang nakahiga lamang sa banig, naglalaro, o nakatingin sa labas ng bintana habang abalang-abala ang kanyang ina sa mga gawain.\n\n“Pinya, anak, pakitulungan mo naman ako sa paghahanda ng pagkain,” sabi ng kanyang ina habang abala sa pagluluto.\n\nNgunit hindi sumunod si Pinya. Ipinagpatuloy niya ang kanyang ginagawa at hindi niya pinansin ang pagod at pakiusap ng kanyang ina.',
        question: QuestionModel(
          id: 'pinya-q1',
          question: 'Bakit madalas mapagalitan si Pinya?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'Dahil masipag siyang tumulong sa kanyang ina araw-araw.',
            'Dahil hindi siya tumutulong at hindi siya nakikinig sa kanyang ina.',
            'Dahil palagi siyang abala sa pag-aaral sa loob ng bahay.'
          ],
          correctAnswerIndex: 1,
          hint: 'Ano ang ginagawa ni Pinya habang abala ang kanyang ina?',
          encouragement:
              'Nice Work! Tama! Hindi tumutulong si Pinya at hindi siya nakikinig.',
          buddyHintParagraph:
              'Kadalasan, makikita siyang nakahiga lamang sa banig.',
        ),
      ),
      StorySegment(
        id: 'pinya-2',
        content:
            'Isang mainit na hapon, abala ang ina sa pagluluto. Ramdam ang init ng kalan at ang pagod sa kanyang katawan habang patuloy niyang hinahalo ang niluluto upang maiwasang masunog.\n\n“Pinya, anak, pakikuha mo nga ang sandok sa kusina,” sabi niya habang patuloy sa pagluluto.\n\nMabagal na tumayo si Pinya mula sa kanyang hinihigaan at dahan-dahang pumunta sa kusina. Ngunit ilang sandali lang ay bumalik siya sa ina.\n\n“Inay, hindi ko po makita,” sagot niya kahit ang sandok ay nasa malinaw na nakikitang lugar lamang.\n\nNapatigil ang ina at napatingin sa direksyon ng kusina. Napansin niyang ang sandok ay nasa mismong harap lamang ng mesa. Pinilit ng ina na pigilan ang nararamdamang inis.',
        question: QuestionModel(
          id: 'pinya-q2',
          question: 'Ano ang maaaring maramdaman ng ina?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.prediction,
          options: [
            'Maaaring makaramdam ng saya ang ina sa ginawa ni Pinya.',
            'Maaaring makaramdam ng pagkainis o galit ang ina dahil hindi nagsisikap si Pinya.',
            'Maaaring matuwa ang ina sa sagot ni Pinya.'
          ],
          correctAnswerIndex: 1,
          hint:
              'Paulit-ulit na hindi sumusunod si Pinya—ano kaya ang mararamdaman ng ina?',
          encouragement:
              'Nice Work! Tama! Naiinis ang ina dahil hindi nagsisikap si Pinya.',
          buddyHintParagraph:
              'Pinilit ng ina na pigilan ang nararamdamang inis.',
        ),
      ),
      StorySegment(
        id: 'pinya-3',
        content:
            'Dahil sa matinding pagod, at bigat ng kanyang nararamdaman, hindi na napigilan ng ina ang kanyang sarili.\n\n“Pinya! Sana magkaroon ka ng maraming mata para makita mo ang hinahanap mo!” sabi niya nang may halong pagod at lungkot.\n\nBiglang natahimik ang paligid. Sa isang saglit, nawala si Pinya at hindi na siya makita sa loob ng kanilang bahay. Hinanap siya ng kanyang ina sa bawat sulok—sa kusina, sa likod ng bahay, at sa bakuran—ngunit wala na siya.\n\nLumipas ang mga araw at sa kanilang bakuran ay may tumubong kakaibang halaman. Lumaki ito hanggang sa mamunga, at nang makita ng ina ang bunga, napansin niyang ito ay may maraming “mata.”\n\nDoon niya unti-unting naunawaan ang nangyari—tila si Pinya ay naging bahagi ng halaman na iyon.',
        question: QuestionModel(
          id: 'pinya-q3',
          question: 'Ano ang nararamdaman ng ina matapos mawala si Pinya?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.emotion,
          options: [
            'Nakaramdam ng matinding lungkot at pagsisisi ang ina sa nangyari sa kanyang anak.',
            'Nakaramdam ng saya ang ina dahil nawala si Pinya.',
            'Wala siyang naramdamang kahit ano sa pagkawala ni Pinya.'
          ],
          correctAnswerIndex: 0,
          hint:
              'Balikan ang pangyayari: ano ang nangyari matapos mawala si Pinya?',
          encouragement: 'Nice Work! Tama! Nalungkot at nagsisisi ang ina.',
          buddyHintParagraph: 'Doon niya unti-unting naunawaan ang nangyari.',
        ),
      ),
      StorySegment(
        id: 'pinya-4',
        content:
            'Araw-araw, inaalagaan ng ina ang halaman bilang alaala ng kanyang anak. Dinidiligan niya ito at tinitingnan nang may pagmamahal at pag-alala. Sa tuwing nakikita niya ang pinya, naaalala niya ang mga oras na hindi sila nagkaintindihan at ang mga salitang nasabi niya dahil sa kanyang pagod.\n\nSimula noon, naging paalala ang pinya sa lahat—lalo na sa mga bata—na mahalagang makinig sa magulang, tumulong sa mga gawain, at pahalagahan sila habang sila ay naroon pa.',
        question: QuestionModel(
          id: 'pinya-q4',
          question: 'Ano ang aral ng kuwento?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'Mahalagang makinig at tumulong ang mga anak sa kanilang mga magulang.',
            'Mas mabuti na maging tamad at iwasan ang mga gawain sa bahay.',
            'Dapat umiwas ang mga bata sa pagtulong sa kanilang pamilya.'
          ],
          correctAnswerIndex: 0,
          hint:
              'Balikan ang huling bahagi: ano ang paalala ng pinya sa mga bata?',
          encouragement:
              'Napakagaling! Tama! Batay sa kuwento, mahalagang makinig at tumulong sa magulang.',
          buddyHintParagraph: 'Simula noon, naging paalala ang pinya sa lahat.',
        ),
      ),
    ],
  ),

  // STORY 2 - INTERMEDIATE
  StoryModel(
    id: 'alamat-ng-parol',
    title: 'Ang Alamat ng Parol ng Bayan',
    author: 'KuwentoBuddy',
    coverImage:
        'assets/images/tropical_jungle_adventure_children_illustration_null_1773063139698.jpg', // Placeholder
    description:
        'Isang kuwento tungkol sa isang maliit na bayang natutong magtulungan, at kung paano naging simbolo ang parol ng kanilang pagkakaisa.',
    level: StoryLevel.intermediate,
    categories: [StoryCategory.filipinoTales],
    estimatedMinutes: 6,
    language: 'fil',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    sequenceActivity: [
      'Nagkaroon ng problema sa bayan dahil humina ang pagtutulungan ng mga tao.',
      'Napansin ni Lira na humihina ang pagtutulungan sa bayan.',
      'Nawalan ng ilaw ang buong bayan dahil sa malakas na bagyo.',
      'Nagsimulang gumawa ng parol ang mga kabataan at mga tao.',
      'Unti-unting tumulong ang buong bayan sa paggawa ng parol.',
      'Nagliwanag ang parol at nagbigay ng pag-asa sa lahat.',
      'Naging simbolo ito ng pagkakaisa at pag-asa ng bayan.'
    ],
    segments: [
      StorySegment(
        id: 'parol-opening',
        content:
            'Page 1 (Opening Page)\nTitle: Ang Alamat ng Parol ng Bayan\nGenre: Filipino Tale\nLevel: Intermediate\nLanguage: Filipino\nSynopsis:\nIsang kuwento tungkol sa isang maliit na bayang napapalibutan ng mga burol, ilog, at malalawak na bukirin. Sa kabila ng tahimik at payapang pamumuhay, dumating ang isang pagsubok na nagpaiba sa kanilang samahan. Sa gitna ng dilim at problema, natutunan ng mga tao ang kahalagahan ng pagtutulungan, pag-asa, at pagkakaisa. Mula sa isang simpleng parol na kanilang ginawa, ito ay naging simbolo ng liwanag na nagbubuklod sa buong komunidad.\nSource / Reference:\nOriginal Filipino-inspired folktale – Adapted for KuwentoBuddy\nHeads Up:\nAng kuwento ay may checkpoint questions sa bawat bahagi.\n\nBasahin nang mabuti at unawain ang damdamin at pangyayari sa kuwento bago sumagot.\n\nPinakamainam para sa gabay na pagdedesisyon.',
      ),
      StorySegment(
        id: 'parol-1',
        content:
            'Noong unang panahon, may isang maliit na bayang tahimik na napapalibutan ng mga burol, ilog, at mga punongkahoy. Ang mga tao rito ay simple lamang ang pamumuhay ngunit masayahin at likas na marunong magtulungan sa araw-araw na gawain tulad ng paglilinis, pagtatanim, at pag-aalaga sa kanilang paligid.\n\nSa gitna ng bayang ito ay may isang batang nagngangalang Lira. Siya ay kilala sa pagiging masipag, matulungin, at laging handang umalalay sa iba, lalo na kapag may problema sa kanilang komunidad.\n\nHabang lumilipas ang mga araw, napansin ni Lira na unti-unting nagbabago ang samahan ng mga tao. May mga hindi na nagkakakilala, ang iba ay abala sa sarili, at may ilan na hindi na nagtutulungan tulad ng dati.\n\nDahil dito, nakaramdam si Lira ng pag-aalala. Alam niya na kapag nawala ang pagtutulungan, mahihirapan ang buong bayan.\n\nKaya’t nag-isip siya ng paraan kung paano muling mapaglapit ang mga tao sa kanilang lugar.',
        question: QuestionModel(
          id: 'parol-q1',
          question: 'Bakit nag-alala si Lira sa kanilang bayan?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'Dahil nagiging magulo at walang tao sa bayan',
            'Dahil unti-unting nawawala ang pagtutulungan ng mga tao',
            'Dahil ayaw na niyang tumira sa bayan'
          ],
          correctAnswerIndex: 1,
          hint: 'Ano ang napansin niya sa ugali ng mga tao sa araw-araw?',
          encouragement:
              'Nice Work! Tama! Napansin ni Lira na humihina ang pagtutulungan sa kanilang bayan.',
          buddyHintParagraph:
              'Napansin ni Lira na unti-unting nagbabago ang samahan ng mga tao.',
        ),
      ),
      StorySegment(
        id: 'parol-2',
        content:
            'Isang gabi, habang malakas ang ulan at umiihip ang hangin, biglang nawalan ng ilaw ang buong bayan. Naging madilim ang paligid at mas lalo itong nagdulot ng takot sa ilang tao, lalo na sa mga bata at matatanda.\n\nDahil sa pangyayaring ito, nagtipon si Lira kasama ang ilang kabataan sa kanilang lugar. Nagdala sila ng mga simpleng gamit tulad ng lumang bote, papel, pandikit, at kandila upang makagawa ng parol na maaaring magbigay ng liwanag.\n\nHabang sila ay gumagawa, unti-unting lumabas ang ibang tao upang tumulong. May nagdala ng karagdagang kandila, may nag-gupit ng papel, at may tumulong sa pagbuo ng disenyo.\n\nSa hindi inaasahan, habang abala sila sa paggawa ng parol, muling nabuhay ang pag-uusap, tawanan, at pagtutulungan sa buong bayan.',
        question: QuestionModel(
          id: 'parol-q2',
          question: 'Ano ang naramdaman ng mga tao habang gumagawa ng parol?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.emotion,
          options: [
            'Natakot at umiwas sa isa’t isa',
            'Masaya at muling nagkakaisa',
            'Naiinis at nag-away'
          ],
          correctAnswerIndex: 1,
          hint:
              'Pansinin kung ano ang nangyari habang sila ay magkakasamang gumagawa.',
          encouragement:
              'Nice Work! Tama! Masaya at nagkakaisa ang mga tao habang gumagawa ng parol.',
          buddyHintParagraph:
              'muling nabuhay ang pag-uusap, tawanan, at pagtutulungan',
        ),
      ),
      StorySegment(
        id: 'parol-3',
        content:
            'Pagkatapos ng mahabang gabi ng pagtutulungan, natapos nila ang parol na gawa sa simpleng materyales. Bagama’t simple lamang ito sa anyo, nang ito ay sindihan, nagliwanag ito nang mas maliwanag kaysa sa inaasahan ng lahat.\n\nAng liwanag ng parol ay hindi lamang nagtanggal ng dilim sa kanilang paligid, kundi nagbigay rin ng pakiramdam ng pag-asa at kapanatagan sa mga tao.\n\nMula noon, naging bahagi na ng kanilang kaugalian ang paggawa ng parol tuwing may pagsubok. Ginagamit nila ito bilang paalala na sa pamamagitan ng pagtutulungan, anumang problema ay mas madaling malalampasan.',
        question: QuestionModel(
          id: 'parol-q3',
          question: 'Ano ang sinisimbolo ng parol sa kuwento?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.prediction,
          options: [
            'Ang parol ay simbolo ng yaman at kayamanan',
            'Ang parol ay simbolo ng pagkakaisa at pag-asa',
            'Ang parol ay simbolo ng takot sa dilim'
          ],
          correctAnswerIndex: 1,
          hint: 'Ano ang naramdaman ng mga tao nang sila ay nagtulungan?',
          encouragement:
              'Very good! Tama! Ang parol ay simbolo ng pagkakaisa at pag-asa.',
          buddyHintParagraph:
              'Mula noon, naging bahagi na ng kanilang kaugalian',
        ),
      ),
      StorySegment(
        id: 'parol-4',
        content:
            'Sa paglipas ng maraming taon, ang parol ay naging mahalagang bahagi ng kanilang kultura at tradisyon. Hindi lamang ito ginagamit tuwing may selebrasyon, kundi nagsisilbi rin itong paalala ng kanilang pinagsamahan bilang isang bayan.\n\nHanggang ngayon, ang liwanag ng parol ay patuloy na sumisimbolo sa pag-asa. Ipinapaalala nito na kahit may dilim, bagyo, o problema sa buhay, mas nagiging matatag ang mga tao kapag sila ay nagkakaisa at nagtutulungan.',
        question: QuestionModel(
          id: 'parol-q4',
          question: 'Bakit naging mahalaga ang parol sa bayan?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'Dahil ito ay maganda lamang tingnan',
            'Dahil ito ay paalala ng pagkakaisa at pagtutulungan',
            'Dahil ito ay mahal at bihira'
          ],
          correctAnswerIndex: 1,
          hint: 'Ano ang natutunan ng mga tao mula sa kanilang karanasan?',
          encouragement:
              'Napakagaling! Tama! Ang parol ay paalala ng pagkakaisa at pagtutulungan.',
          buddyHintParagraph:
              'nagsisilbi rin itong paalala ng kanilang pinagsamahan',
        ),
      ),
    ],
  ),

  // STORY 3 - ADVANCED
  StoryModel(
    id: 'alamat-ng-bulkang-mayon',
    title: 'Ang Alamat ng Bulkang Mayon',
    author: 'Bicolano Folktale',
    coverImage:
        'assets/images/magical_forest_fairy_tale_children_book_illustration_null_1773063134827.jpg', // Placeholder
    description:
        'Isang alamat tungkol sa pag-ibig nina Daragang Magayon at Panganoron. Ipinapakita nito ang lakas ng damdamin, kapalaran, at pagbuo ng Bulkang Mayon.',
    level: StoryLevel.advanced,
    categories: [StoryCategory.filipinoTales],
    estimatedMinutes: 8,
    language: 'fil',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    sequenceActivity: [
      'Si Daragang Magayon ay kilala sa kanyang pambihirang kagandahan sa kanilang lugar.',
      'Minahal niya si Panganoron na isang matapang at marangal na mandirigma.',
      'May isang makapangyarihang datu na nais din siyang pakasalan.',
      'Tumanggi si Magayon dahil hindi niya mahal ang datu.',
      'Nagkaroon ng matinding labanan sa pagitan ng datu at ni Panganoron.',
      'Sa gitna ng labanan, tinamaan si Panganoron ng pana.',
      'Hindi nakaligtas si Panganoron sa kanyang sugat.',
      'Sa labis na kalungkutan, sumunod at pumanaw si Magayon.',
      'Inilagay sila sa iisang lugar bilang simbolo ng kanilang pag-ibig.',
      'Sa paglipas ng panahon, nabuo ang Bulkang Mayon sa lugar ng kanilang libingan.'
    ],
    segments: [
      StorySegment(
        id: 'mayon-opening',
        content:
            'Page 1 (Opening Page)\nTitle: Ang Alamat ng Bulkang Mayon\nGenre: Filipino Tale\nLevel: Advanced\nLanguage: Filipino\nSynopsis:\nIsang alamat tungkol sa pag-ibig nina Daragang Magayon at Panganoron. Ipinapakita nito ang lakas ng damdamin, kapalaran, at pagbuo ng Bulkang Mayon bilang simbolo ng kanilang kuwento.\nSource / Reference:\nBicolano Folktale – Public Domain\nAdapted for KuwentoBuddy\nHeads Up:\nAng kuwentong ito ay may mas malalim na damdamin at pangyayari.\n\nMagbasa nang mabuti at pag-isipan ang bawat desisyon at emosyon ng mga tauhan.\n\nPinakamainam para sa gabay na pagkatuto at mas malalim na pagninilay.',
      ),
      StorySegment(
        id: 'mayon-1',
        content:
            'Sa malayong lupain ng Bicol, sa paanan ng mga bundok at baybayin na dinarayo ng hangin mula sa dagat, nakatira ang isang dalagang kilala sa pangalang Daragang Magayon. Siya ay hindi lamang hinahangaan dahil sa kanyang pambihirang kagandahan, kundi pati na rin sa kanyang kabutihang-loob at pagiging mapagpakumbaba sa kabila ng kanyang katanyagan.\n\nDahil dito, maraming datu, mandirigma, at makapangyarihang lalaki sa iba’t ibang kaharian ang nagnanais na mapasakanya. Bawat isa ay nag-aalok ng kayamanan, kapangyarihan, at impluwensiya. Ngunit sa kabila ng lahat ng ito, isang tao lamang ang tunay na nakakuha ng kanyang puso—si Panganoron, isang mandirigmang kilala sa tapang, dangal, at katapatan.\n\nNgunit hindi lahat ay nasiyahan sa kanilang pagmamahalan. May isang makapangyarihang datu na matagal nang naghahangad kay Magayon at hindi matanggap ang kanyang pagtanggi, kahit pa malinaw na hindi ito sinuklian ng damdamin.',
        question: QuestionModel(
          id: 'mayon-q1',
          question: 'Bakit ayaw ni Magayon sa datu?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'Ayaw niya sa datu dahil ito ay mahirap at walang kapangyarihan.',
            'Ayaw niya sa datu dahil hindi niya ito tunay na minamahal.',
            'Ayaw niya sa datu dahil hindi niya ito kilala.'
          ],
          correctAnswerIndex: 1,
          hint:
              'Balikan ang pagpili ni Magayon: Sino lamang ang kanyang minahal sa kuwento?',
          encouragement:
              'Nice Work! Tama! Pinili ni Magayon ang tunay na pag-ibig kaysa sa kapangyarihan.',
          buddyHintParagraph:
              'Isang tao lamang ang tunay na nakakuha ng kanyang puso—si Panganoron.',
        ),
      ),
      StorySegment(
        id: 'mayon-2',
        content:
            'Hindi matanggap ng datu ang matinding pagtanggi sa kanya. Ang kanyang pagmamataas ay nasugatan, kaya’t sa halip na tanggapin ito, pinili niyang maghasik ng galit. Dahil dito, nauwi sa tensyon at pag-aaway sa pagitan ng kanilang mga tauhan at ni Panganoron.\n\nSa gitna ng kaguluhan, habang pilit na lumalaban si Panganoron upang protektahan si Magayon, isang ligaw na pana ang tumama sa kanya, kaya siya ay napahina. Hindi niya ito inaasahan. Sa isang iglap, bumagsak siya sa lupa.\n\nSa di-kalayuan, nakita ito ni Magayon at napaluhod sa gulat at matinding takot. Hawak ang kanyang dibdib, hindi niya lubos maisip ang nangyayari sa harap niya.',
        question: QuestionModel(
          id: 'mayon-q2',
          question: 'Ano ang maaaring naramdaman ni Magayon sa nangyari?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.emotion,
          options: [
            'Nakaramdam siya ng saya sa nangyari kay Panganoron .',
            'Nakaramdam siya ng matinding lungkot at galit sa sinapit ng kanyang minamahal.',
            'Wala siyang naramdamang emosyon sa pangyayari.'
          ],
          correctAnswerIndex: 1,
          hint:
              'Balikan ang pangyayari sa labanan: ano ang nangyari kay Magayon at Panganoron?',
          encouragement:
              'Very good! Tama ang iyong pag-unawa sa lalim ng damdamin ni Magayon .',
          buddyHintParagraph: 'napaluhod sa gulat at matinding takot.',
        ),
      ),
      StorySegment(
        id: 'mayon-3',
        content:
            'Hindi nagtagal matapos ang trahedya, hindi na rin kinaya ni Magayon ang bigat ng kanyang nararamdaman. Sa labis na kalungkutan, pinili niyang manatili sa lugar kung saan sila huling magkasama, dala ang matinding kalungkutan.\n\nSa paglipas ng panahon, nagbago ang lugar at napapalibutan ng damo at mga puno. Walang ingay, walang gulo—tanging katahimikan lamang ang naiwan.\n\nSa paglipas ng panahon, ang lugar na iyon ay unti-unting nagbago. Ang lupa ay umangat, at mula rito ay nabuo ang isang kahanga-hangang anyo ng bundok na may perpektong hugis kono—ang Bulkang Mayon.\n\nSinasabi ng mga tao na ang anyo ng bulkan ay sumasalamin sa damdaming hindi kailanman nawala sa kanilang pag-ibig.',
        question: QuestionModel(
          id: 'mayon-q3',
          question: 'Ano ang sinisimbolo ng Bulkang Mayon sa kuwento?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.prediction,
          options: [
            'Ipinapakita nito ang kasiyahan at katahimikan ng lugar.',
            'Ipinapahiwatig nito ang matinding damdamin at alaala ng kanilang pag-ibig.',
            'Ipinapakita nito na walang nangyaring mahalagang kuwento sa lugar.'
          ],
          correctAnswerIndex: 1,
          hint:
              'Isipin ang bulkan bilang simbolo—ano ang maaaring kinakatawan nito?',
          encouragement:
              'Nice Work! Naiugnay mo ang bulkan sa matinding damdamin ng kuwento.',
          buddyHintParagraph:
              'ang anyo ng bulkan ay sumasalamin sa damdaming hindi kailanman nawala',
        ),
      ),
      StorySegment(
        id: 'mayon-4',
        content:
            'Hanggang sa kasalukuyan, ang Bulkang Mayon ay patuloy na hinahangaan hindi lamang dahil sa kagandahan nito, kundi dahil sa alamat na nakaugnay dito. Kapag ito ay nag-aalburuto, sinasabi ng ilan na ito ay paalala ng damdaming hindi kailanman namamatay—ang pag-ibig nina Magayon at Panganoron.\n\nSa mata ng mga tao, ang bulkan ay hindi lamang anyo ng kalikasan, kundi isang paalala ng sakripisyo, kapalaran, at pag-ibig na lumampas sa hangganan ng buhay.',
        question: QuestionModel(
          id: 'mayon-q4',
          question: 'Ano ang pangunahing tema ng kuwento?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'Ang kuwento ay nagpapakita ng pag-ibig at sakripisyo ng dalawang tao.',
            'Ang kuwento ay tungkol sa paghahanap ng kayamanan.',
            'Ang kuwento ay nakatuon lamang sa katatawanan.'
          ],
          correctAnswerIndex: 0,
          hint:
              'Balikan ang buong kuwento—ano ang pinakapinapakita ng kanilang karanasan?',
          encouragement:
              'Napakagaling! Nauunawaan mo ang malalim na tema ng pag-ibig at sakripisyo.',
          buddyHintParagraph:
              'isang paalala ng sakripisyo, kapalaran, at pag-ibig',
        ),
      ),
    ],
  ),
  StoryModel(
    id: 'huni-ng-duyan-sa-punong-kawayan',
    title: 'Ang Huni ng Duyan sa Punong Kawayan',
    author: 'KuwentoBuddy Original',
    coverImage: 'assets/images/alamat_ng_pinya_cover_photo.jpg',
    description:
        'Isang batang nakaririnig ng mahinhing huni mula sa lumang duyan at natututuhan na ang kabutihan at pagtutulungan ay may sariling himig.',
    localizedTitles: {
      'en': 'The Hum of the Bamboo Cradle',
    },
    level: StoryLevel.beginner,
    categories: [StoryCategory.filipinoTales],
    estimatedMinutes: 5,
    language: 'fil',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    sequenceActivity: [
      'Narinig ni Laya ang mahinhing huni mula sa lumang duyan.',
      'Sinundan niya ang tunog hanggang sa kubong may kawayan.',
      'Tumulong siya sa mga gawain sa bahay at sa kapitbahay.',
      'Napatunayan niyang lumalakas ang himig kapag sama-samang mabuti ang loob ng mga tao.',
    ],
    segments: [
      StorySegment(
        id: 'huni-duyan-opening',
        content: '''Page 1 (Opening Page)
Title: Ang Huni ng Duyan sa Punong Kawayan
Genre: Filipino Tale
Level: Beginner
Language: Filipino
Synopsis:
Sa isang bayang malapit sa ilog at mga punong kawayan, may batang si Laya na palaging nakaririnig ng mahinhing huni mula sa lumang duyan tuwing dapithapon. Hindi niya alam kung hangin ba iyon, o kung may lihim na gustong iparating ang tunog. Sa bawat pagsunod niya sa himig, natututuhan niyang ang kabutihan, pag-alalay, at pakikinig ay may sariling awit na nadarama ng buong komunidad.
Source / Reference:
Original Filipino-inspired folktale
Adapted for KuwentoBuddy
Heads Up:
May checkpoint questions sa bawat bahagi.

Basahin nang mabuti at pag-isipan ang mga pangyayari bago sumagot.

Pinakamainam para sa gabay na panimulang pagkatuto.''',
      ),
      StorySegment(
        id: 'huni-duyan-1',
        content:
            '''Tuwing hapon, matapos ang maiinit na gawain sa bukid, umuupo si Laya sa ilalim ng kubong kawayan ng kanyang lola. Doon niya unang narinig ang mahinhing huni. Hindi ito malakas, ngunit tila may dalang lambing na pumapawi sa pagod.

“Lola, may kumakanta po ba sa duyan?” tanong niya.

Ngumiti ang lola. “Kapag payapa ang loob ng bahay at marunong magtulungan ang mga tao, parang may himig na sumusunod sa hangin,” sabi niya.

Napaisip si Laya. Ang salitang himig ay bago sa kanya, pero sa paraan ng pagtugon ng lola, parang ibig nitong sabihing may tunog na mas nararamdaman kaysa naririnig.''',
        question: QuestionModel(
          id: 'huni-duyan-q1',
          question:
              'Bakit kaya nakaririnig si Laya ng mahinhing huni sa duyan?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'A. Dahil may tumatangay na ibon sa duyan',
            'B. Dahil sira ang mga kahoy at nag-iingay ito',
            'C. Dahil ang duyan ay sumasagisag sa payapang tahanan at pagtutulungan',
          ],
          correctAnswerIndex: 2,
          hint: 'Pakinggan ang paliwanag ng lola at ang salitang himig.',
          encouragement:
              'Tama! Ang huni ay paalala ng payapang bahay at pagkakaisa.',
          buddyHintParagraph:
              'Kapag payapa ang loob ng bahay at marunong magtulungan ang mga tao, parang may himig na sumusunod sa hangin.',
        ),
      ),
      StorySegment(
        id: 'huni-duyan-2',
        content:
            '''Kinabukasan, may kapitbahay na dumating upang humiram ng bigas dahil may bisita silang inaasikaso. Sa mismong oras na iyon, abala si Laya sa paglalaro at gusto na sana niyang tumakbo palayo. Ngunit nakita niya ang pagod sa mukha ng kanyang lola at ang pag-aalala ng kapitbahay.

Sa halip na umalis, kinuha niya ang maliit na salok at tumulong sa pagbubuhat ng bigas. Habang ginagawa niya ito, naramdaman niyang mas gumagaan ang paligid.

“Mabigat po ba?” tanong niya.

“Mabigat man sa kamay, magaan naman sa puso kapag may kasamang alalay,” sagot ng lola.

Nalaman ni Laya na ang alalay ay hindi lamang pagbubuhat ng gamit. Ito rin ay pagdadala ng pag-aalala ng iba nang may malasakit.''',
        question: QuestionModel(
          id: 'huni-duyan-q2',
          question: 'Paano ipinakita ni Laya ang malasakit sa kapitbahay?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.emotion,
          options: [
            'A. Tumulong siya sa pagbubuhat ng bigas at hindi tumalikod sa pangangailangan',
            'B. Tinago niya ang bigas upang hindi makapanghiram ang kapitbahay',
            'C. Pinanood lang niya ang kapitbahay habang abala ang lahat',
          ],
          correctAnswerIndex: 0,
          hint:
              'Balikan ang ginawa niya nang makita ang pagod ng lola at kapitbahay.',
          encouragement:
              'Tama! Tumulong si Laya sa paraang nakita niyang kailangan ng iba.',
          buddyHintParagraph:
              'Kinuha niya ang maliit na salok at tumulong sa pagbubuhat ng bigas.',
        ),
      ),
      StorySegment(
        id: 'huni-duyan-3',
        content:
            '''Sa gabi ng munting pagdiriwang sa barangay, dinala ng mga tao ang pagkaing inihanda nila. Ang duyan sa kubo ni Laya ay hindi na payapa lamang na nakasabit; tila sumasabay ito sa tawa, kuwentuhan, at pagdalo ng mga kapitbahay.

Noon niya napansin na mas malinaw ang mahinhing huni kapag ang mga tao ay nagkakaisa at hindi nagmamadali na unahin ang sarili. Sa bawat pag-abot ng pagkain at bawat ngiti, nagiging mas magaan ang tunog ng hangin.

“Laya,” sabi ng lola, “ang kabutihan ay parang awit. Kapag ibinahagi, mas tumatagal.”

Ngumiti si Laya. Naunawaan niyang ang duyan ay hindi lamang gamit sa pagtulog. Isa rin itong paalala na ang mabuting gawa ay may alon na umaabot sa buong komunidad.''',
        question: QuestionModel(
          id: 'huni-duyan-q3',
          question: 'Ano ang ipinahihiwatig ng duyan sa dulo ng kuwento?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'A. Na kailangang itago ng bawat isa ang lahat para maging payapa',
            'B. Na ang mabubuting gawa ay may kakayahang magpabago sa buong komunidad',
            'C. Na ang duyan ay simbolo lamang ng pagtulog',
          ],
          correctAnswerIndex: 1,
          hint: 'Ano ang natutuhan ni Laya tungkol sa kabutihan?',
          encouragement:
              'Napakagaling! Naintindihan mo ang aral ng pagbabahagi at pagkakaisa.',
          buddyHintParagraph:
              'Ang kabutihan ay parang awit. Kapag ibinahagi, mas tumatagal.',
        ),
      ),
    ],
  ),
  StoryModel(
    id: 'butil-ng-tala-sa-ilalim-ng-balete',
    title: 'Ang Butil ng Tala sa Ilalim ng Balete',
    author: 'KuwentoBuddy Original',
    coverImage:
        'assets/images/magical_forest_fairy_tale_children_book_illustration_null_1773063134827.jpg',
    description:
        'Dalawang magkapatid ang sumusunod sa liwanag sa ilalim ng balete at natutuhang ang pag-aalaga sa tubig at pangako ay mas mahalaga kaysa sa pag-angkin.',
    localizedTitles: {
      'en': 'The Star Seed Beneath the Balete Tree',
    },
    level: StoryLevel.advanced,
    categories: [StoryCategory.filipinoTales],
    estimatedMinutes: 7,
    language: 'fil',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    sequenceActivity: [
      'Natuyo ang munting sapa sa paanan ng burol.',
      'Sinundan ng magkapatid ang liwanag sa ilalim ng balete.',
      'Nakakita sila ng butil na kumikislap na parang tala.',
      'Pinili nilang ibahagi ang natitirang tubig sa mga kapitbahay.',
      'Bumalik ang bukal matapos nilang tuparin ang pangako.',
    ],
    segments: [
      StorySegment(
        id: 'butil-tala-opening',
        content: '''Page 1 (Opening Page)
Title: Ang Butil ng Tala sa Ilalim ng Balete
Genre: Filipino Tale
Level: Advanced
Language: Filipino
Synopsis:
Sa isang baryong nakaahon sa burol at pilit na pinapawi ng araw ang mga halaman, natuyo ang munting sapa na pinagkukunan ng tubig ng mga tao. Isang gabi, sinundan ng magkapatid na sina Tano at Selya ang liwanag sa ilalim ng balete at nakatagpo ng butil na kumikislap na parang tala. Ngunit ang liwanag ay may kasabay na tanong: itatago ba nila ang tuklas, o ibabahagi ito para sa ikabubuti ng lahat?
Source / Reference:
Original Filipino-inspired folktale
Adapted for KuwentoBuddy
Heads Up:
May checkpoint questions sa bawat bahagi.

Magbasa nang mabuti at isipin ang layunin at bunga ng bawat pasya.

Pinakamainam para sa gabay na pagninilay at mas malalim na pag-unawa.''',
      ),
      StorySegment(
        id: 'butil-tala-1',
        content:
            '''Gabi na nang mapansin nina Tano at Selya na halos wala nang tubig sa sapa. Ang mga dahon ay kulubot, at ang mga palay sa bakuran ay nakayuko na parang pagod na pagod. Habang naglalakad sila pauwi, may nakita silang maliit na sinag na galing sa ilalim ng lumang balete.

“May ilaw sa puno,” bulong ni Selya.

Sinundan nila ang kislap hanggang sa isang hukay na natatakpan ng ugat. Sa gitna nito ay may butil na tila may sariling liwanag. Hindi iyon nakakasilaw, ngunit may hatak na hindi maipaliwanag.

“Huwag nating galawin agad,” sabi ni Tano. “Baka may dahilan kung bakit ito narito.”

Napaisip si Selya. Ang salitang dahilan ay tila may bigat na nagsasabing ang bawat bagay ay may pinanggagalingan at dapat ding alagaan sa tamang paraan.''',
        question: QuestionModel(
          id: 'butil-tala-q1',
          question:
              'Bakit hindi agad kinuha nina Tano at Selya ang kumikislap na butil?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'A. Dahil inakala nilang ginto iyon at gusto nila itong itago',
            'B. Dahil natatakot silang may magalit sa kanila kung hindi nila ito gagalawin',
            'C. Dahil naramdaman nilang may dahilan at responsibilidad ang kanilang natuklasan',
          ],
          correctAnswerIndex: 2,
          hint: 'Pakinggan ang sinabi ni Tano tungkol sa dahilan ng butil.',
          encouragement:
              'Tama! Naunawaan nila na ang natuklasan ay may kaakibat na pananagutan.',
          buddyHintParagraph:
              'Huwag nating galawin agad. Baka may dahilan kung bakit ito narito.',
        ),
      ),
      StorySegment(
        id: 'butil-tala-2',
        content:
            '''Kinabukasan, may dumating na matatandang kapitbahay na humihingi ng kaunting tubig para sa mga batang may lagnat. Sa bahay nila, iisa na lamang ang tapayang halos kalahati na lang ang laman.

Mabilis na sumagi sa isip ni Tano na baka mas makabubuti kung itatago muna nila ang natitirang tubig. Ngunit tumingin si Selya sa mga mata ng mga kapitbahay at naalala ang laging sinasabi ng kanilang ina: “Kung may sapat para maibahagi, huwag hayaang maging dahilan ng gutom ang takot sa bukas.”

Pinili nilang ipahiram ang tubig kahit alam nilang mababawasan ang natitira para sa kanilang sariling bahay.

Sa sandaling iyon, napansin ni Tano na mas madaling huminga ang kanyang dibdib. Hindi man nadagdagan ang tubig, parang gumaan naman ang kanilang loob.

Ang salitang pahiram ay hindi na lamang simpleng pag-abot ng salok. Isa na itong pangako na ang pansamantalang kakulangan ay hindi dapat gawing dahilan para isara ang pinto sa iba.''',
        question: QuestionModel(
          id: 'butil-tala-q2',
          question:
              'Paano nila ipinakita ang tamang pagpapasya sa gitna ng kakulangan?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.emotion,
          options: [
            'A. Itinago nila ang tubig para siguradong sa kanila lang ito',
            'B. Ibinahagi nila ang tubig kahit limitado na ito',
            'C. Ginamit nila ang tubig sa pagpuputi ng bakod',
          ],
          correctAnswerIndex: 1,
          hint:
              'Balikan ang ginawa nila nang humingi ng tulong ang mga kapitbahay.',
          encouragement:
              'Tama! Pinili nilang magbahagi kahit may pangambang mabawasan sila.',
          buddyHintParagraph:
              'Pinili nilang ipahiram ang tubig kahit alam nilang mababawasan ang natitira.',
        ),
      ),
      StorySegment(
        id: 'butil-tala-3',
        content:
            '''Nang sumunod na gabi, ibinalik ng mga kapitbahay ang lalagyan at dinalhan sila ng mga punlang gulay at ilang pirasong prutas mula sa mataas na bahagi ng baryo. Sa pag-uwi nila, muli silang dumaan sa balete at nakita na ang liwanag ng butil ay naging manipis na sinag na papalapit sa lupa.

Kinabukasan, tumulo ang unang patak mula sa pinakatuktok ng burol. Pagkatapos ay sunod-sunod na umaagos ang malinaw na tubig na para bang matagal na itong naghintay na may magbigay-pugay sa kanya.

“Hindi natin inangkin ang hiwaga,” sabi ni Selya. “Pinangalagaan natin ito.”

At doon nila naunawaan na ang butil ng tala ay hindi lamang mahiwagang bagay. Isa itong paalala na ang pag-ibig sa lupa, tubig, at kapwa ay lumalago kapag may pagtitiwala at pananagutan.''',
        question: QuestionModel(
          id: 'butil-tala-q3',
          question: 'Ano ang sinisimbolo ng butil ng tala sa kuwento?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'A. Takot sa dilim at pag-iisa',
            'B. Pagiging sakim at pagtatago ng yaman',
            'C. Pag-asa, pananagutan, at pagbabahagi sa komunidad',
          ],
          correctAnswerIndex: 2,
          hint: 'Ano ang nangyari nang pinili nilang ibahagi ang tubig?',
          encouragement:
              'Napakagaling! Ang butil ay naging simbolo ng pag-asa at malasakit.',
          buddyHintParagraph: 'Pinangalagaan natin ito.',
        ),
      ),
    ],
  ),
  StoryModel(
    id: 'lia-at-ang-mapa-ng-mahinhing-alon',
    title: 'Lia at ang Mapa ng Mahinhing Alon',
    author: 'KuwentoBuddy Original',
    coverImage:
        'assets/images/tropical_jungle_adventure_children_illustration_null_1773063139698.jpg',
    description:
        'Sinundan ni Lia ang isang lumang mapa sa tabing-dagat at natutuhan niyang ang pag-usisa ay mas ligtas kapag may pag-iingat at malasakit sa kasama.',
    localizedTitles: {
      'en': 'Lia and the Map of Whispering Waves',
    },
    level: StoryLevel.beginner,
    categories: [StoryCategory.adventureJourney],
    estimatedMinutes: 5,
    language: 'en',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    sequenceActivity: [
      'Nakakita si Lia ng lumang mapa sa loob ng kabibe.',
      'Sinundan niya ang mga palatandaan sa daan ng buhangin at kawayan.',
      'Tinulungan niya ang batang pinsan na maglakad sa tulay na lumiliyad.',
      'Natagpuan niya ang nawawalang kompas ng mangingisda sa isang lihim na look.',
    ],
    segments: [
      StorySegment(
        id: 'lia-map-opening',
        content: '''Page 1 (Opening Page)
Title: Lia at ang Mapa ng Mahinhing Alon
Genre: Adventure & Journey Story
Level: Beginner
Language: English
Synopsis:
On a coastal morning after a short rain, Lia finds an old map tucked inside a shell box near her grandmother’s hut. The map contains short clues written in a fading hand, and the clues seem to point toward a hidden cove beyond the bamboo bridge. As Lia follows the trail, she learns that curiosity becomes wiser when it is guided by caution, patience, and care for the people walking beside us.
Source / Reference:
Original adventure story
Adapted for KuwentoBuddy
Heads Up:
May checkpoint questions in every section.

Read carefully and think before answering.

Best for guided introduction.''',
      ),
      StorySegment(
        id: 'lia-map-1',
        content:
            '''Lia was helping her grandmother sort shells when she noticed a tiny map rolled into a shell box. The paper was soft at the edges, and one line could still be read: “Follow the hush after the rain.”

Lia frowned. She did not know the word hush at first, but the clue itself felt calm. It reminded her of the quiet sound she heard when the sea settled after a storm.

She tucked the map into her pocket and looked toward the path that curved behind the bamboo trees. The path seemed ordinary, yet the map made it feel important.

“If the clue is asking me to listen, then I should walk slowly,” she whispered.''',
        question: QuestionModel(
          id: 'lia-map-q1',
          question: 'What does the word hush most likely mean in the clue?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'A. A loud crashing noise',
            'B. A quiet and gentle sound',
            'C. A bright and flashing light',
          ],
          correctAnswerIndex: 1,
          hint: 'Think about the sea after a storm and the way Lia reacts.',
          encouragement:
              'Correct! Hush means a quiet, gentle sound in this context.',
          buddyHintParagraph: 'Follow the hush after the rain.',
        ),
      ),
      StorySegment(
        id: 'lia-map-2',
        content:
            '''A narrow bamboo bridge led across a shallow stream before the path climbed toward the cove. Lia’s younger cousin, Pio, had followed her without asking. At first, he laughed and ran ahead, but the bridge swayed under his feet.

Lia stopped immediately. She held out her hand and told Pio to step slowly and match her pace. The boards creaked, but they crossed safely.

On the far side, Pio asked why she was not rushing like in the stories they heard from older cousins.

“Because a journey is not better when it is faster,” Lia said. “It is better when everyone reaches the end safely.”

Her map still pointed forward, but now she understood that the companion beside her mattered as much as the destination.''',
        question: QuestionModel(
          id: 'lia-map-q2',
          question: 'How did Lia show good judgment on the bridge?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.emotion,
          options: [
            'A. She asked Pio to slow down and cross carefully with her',
            'B. She left Pio behind and ran ahead alone',
            'C. She jumped across without checking the bridge',
          ],
          correctAnswerIndex: 0,
          hint: 'What did Lia do when she saw the bridge sway?',
          encouragement:
              'Tama! Pinili ni Lia ang ligtas na paraan para sa kanilang dalawa.',
          buddyHintParagraph:
              'She held out her hand and told Pio to step slowly and match her pace.',
        ),
      ),
      StorySegment(
        id: 'lia-map-3',
        content:
            '''At the cove, Lia found an old fisherman sitting beside a net with a broken knot. He smiled when he saw the shell box in her hand.

“That map belonged to my brother,” he said. “He hid it so someone kind would bring back my compass.”

Near the rocks, Lia spotted the missing compass, caught between two stones.

She returned it gently. When the fisherman opened it, the needle pointed to a tide pool filled with small glowing shells.

The fisherman explained that the compass had been used not to rush from place to place, but to guide helpers toward people who needed patience and care.

Lia looked at the shell map again and understood: a journey can lead to discovery, but it can also lead to responsibility.''',
        question: QuestionModel(
          id: 'lia-map-q3',
          question: 'Why was the compass hidden near the cove?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.prediction,
          options: [
            'A. To be sold in the market later',
            'B. To keep it away from the sea forever',
            'C. To guide a kind traveler to return it to its owner',
          ],
          correctAnswerIndex: 2,
          hint:
              'Listen to the fisherman’s explanation about kindness and purpose.',
          encouragement:
              'Correct! The compass was hidden so a kind person could find and return it.',
          buddyHintParagraph:
              'He hid it so someone kind would bring back my compass.',
        ),
      ),
    ],
  ),
  StoryModel(
    id: 'daan-ng-orasan-sa-ulap-na-gulod',
    title: 'The Clockmaker’s Path to Cloud Ridge',
    author: 'KuwentoBuddy Original',
    coverImage:
        'assets/images/underwater_ocean_mermaid_children_story_null_1773063136715.png',
    description:
        'Naglakad si Rafael sa mahamog na daan upang maihatid ang mga piyesa ng orasan ng kanyang lolo at natutuhan niyang ang pag-iingat ay mahalaga sa gitna ng hamon.',
    localizedTitles: {
      'fil': 'Ang Daan ng Tagapag-ayos ng Orasan sa Ulap na Gulod',
    },
    level: StoryLevel.intermediate,
    categories: [StoryCategory.adventureJourney],
    estimatedMinutes: 6,
    language: 'en',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    sequenceActivity: [
      'Tinanggap ni Rafael ang sira-sirang orasan mula sa kanyang lolo.',
      'Umakyat siya sa daan papunta sa Cloud Ridge.',
      'Nabanaag niya ang dalawang landas sa gitna ng hamog.',
      'Pinili niyang sumunod sa ligtas na bakas at natapos ang paglalakbay.',
    ],
    segments: [
      StorySegment(
        id: 'clockmaker-opening',
        content: '''Page 1 (Opening Page)
Title: The Clockmaker’s Path to Cloud Ridge
Genre: Adventure & Journey Story
Level: Intermediate
Language: English
Synopsis:
A mountain village waits for its festival bell, but the clock that guides the bell has stopped at 5:30. Rafael, the grandson of the village clockmaker, is asked to carry the broken parts up to Cloud Ridge before the fog grows thicker. As he travels, he must choose between the shortest route and the safest one, learning that sometimes the clearest destination is reached by careful steps rather than hurried ones.
Source / Reference:
Original adventure story
Adapted for KuwentoBuddy
Heads Up:
May checkpoint questions after each part.

Read carefully and think before answering.

Best for guided decision-making.''',
      ),
      StorySegment(
        id: 'clockmaker-1',
        content:
            '''Rafael held the broken clock parts carefully in a cloth wrapped by his grandfather. The hands had stopped at 5:30, and his grandfather explained that the village bell had once been set to that time to warn farmers when the fog usually began to thicken on the ridge.

“So the clock is not only for telling time,” Rafael said.

His grandfather nodded. “It is also for keeping people safe.”

Rafael looked at the pieces again and noticed a tiny crack near the gear. It was not enough to shatter the clock, but it was enough to make him realize that small damage can cause a larger problem if ignored.''',
        question: QuestionModel(
          id: 'clockmaker-q1',
          question:
              'Why did Rafael’s grandfather keep the broken clock parts carefully wrapped?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'A. Because the parts were useless and should be forgotten',
            'B. Because the clock had an important role in guiding the village safely',
            'C. Because he wanted to hide the clock from everyone forever',
          ],
          correctAnswerIndex: 1,
          hint: 'Think about the bell and why 5:30 mattered.',
          encouragement:
              'Correct! The clock had a safety purpose, not just a decorative one.',
          buddyHintParagraph: 'It is also for keeping people safe.',
        ),
      ),
      StorySegment(
        id: 'clockmaker-2',
        content:
            '''As Rafael climbed toward Cloud Ridge, the fog rolled in earlier than expected. He saw two paths: one was narrow and looked quicker, while the other was longer but had small stones painted white along the edge.

He almost chose the shortcut because the festival bell seemed to be calling him from far away. Then he remembered his grandfather’s warning: the shortest path is not always the surest one.

Rafael followed the white stones, and along the way he noticed that the cliffside grass bent sharply toward a drop. The shortcut, he realized, would have taken him too close to the edge.

By choosing the safer path, he did not save time. He saved himself from a mistake he might not have noticed until it was too late.''',
        question: QuestionModel(
          id: 'clockmaker-q2',
          question:
              'What is the best explanation for Rafael’s choice of the longer path?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.prediction,
          options: [
            'A. He wanted to prove he was faster than everyone else',
            'B. He was afraid of the fog and wanted to stop completely',
            'C. He noticed the safer path and chose caution over speed',
          ],
          correctAnswerIndex: 2,
          hint: 'Look at the white stones and the cliffside grass.',
          encouragement:
              'Tama! Pinili ni Rafael ang pag-iingat kaysa sa pagmamadali.',
          buddyHintParagraph:
              'He noticed that the shortcut would have taken him too close to the edge.',
        ),
      ),
      StorySegment(
        id: 'clockmaker-3',
        content:
            '''When Rafael reached the top, the old tower bell was silent. Inside the tower room, he found a tiny note tucked behind the clock face: “The bell keeps time, but the mountain keeps memory.”

He repaired the parts with his grandfather’s instructions in mind and set the hands so the bell would ring again at 5:30.

As the bell sounded across Cloud Ridge, the foghorns in the village answered below. Farmers paused, children hurried home, and the festival lanterns began to glow.

Rafael realized the clock was not simply a family treasure. It was a promise that the village would listen to time, weather, and one another.''',
        question: QuestionModel(
          id: 'clockmaker-q3',
          question:
              'What did Rafael discover about the clock by the end of the journey?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'A. That it was only useful because it looked old',
            'B. That it was a toy with no real purpose',
            'C. That it carried family trust and helped protect the village',
          ],
          correctAnswerIndex: 2,
          hint: 'Consider what happened when the bell rang again.',
          encouragement:
              'Correct! The clock held both family meaning and village responsibility.',
          buddyHintParagraph:
              'It was a promise that the village would listen to time, weather, and one another.',
        ),
      ),
    ],
  ),
  StoryModel(
    id: 'empty-seat-by-the-window',
    title: 'The Empty Seat by the Window',
    author: 'KuwentoBuddy Original',
    coverImage:
        'assets/images/rice_terraces_Philippines_landscape_beautiful_null_1773063138652.jpg',
    description:
        'Isang bagong mag-aaral ang dumarating sa klase, at natututuhan ni Mara na ang simpleng pagbati at pagbabahagi ay maaaring magpaluwag ng kaba ng iba.',
    localizedTitles: {
      'fil': 'Ang Bakanteng Upuan sa Bintana',
    },
    level: StoryLevel.beginner,
    categories: [StoryCategory.socialStories],
    estimatedMinutes: 5,
    language: 'en',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    sequenceActivity: [
      'Napansin ni Mara ang isang bakanteng upuan sa tabi ng bintana.',
      'Nakilala niya ang bagong mag-aaral na mahigpit ang hawak sa kuwaderno.',
      'Ibinahagi niya ang mga krayola at pinakilala ang mga gawain sa silid.',
      'Naging mas masaya ang proyekto nang tumulong ang buong klase.',
    ],
    segments: [
      StorySegment(
        id: 'window-seat-opening',
        content: '''Page 1 (Opening Page)
Title: The Empty Seat by the Window
Genre: Real-Life / Social Story
Level: Beginner
Language: English
Synopsis:
When Mara arrives at school, she notices an empty seat by the window and a new boy standing near the teacher’s desk, holding his notebook very tightly. He looks unsure, as if he is trying to be invisible. Mara must decide whether to stay with her friends or make room for someone who is still finding his place. Through a small act of welcome, she learns how kindness can turn a strange room into a familiar one.
Source / Reference:
Original social story
Adapted for KuwentoBuddy
Heads Up:
May checkpoint questions after each part.

Read carefully and think before answering.

Best for guided introduction.''',
      ),
      StorySegment(
        id: 'window-seat-1',
        content:
            '''Mara placed her bag on the chair beside the window and noticed the boy glance around the classroom. He held his notebook close to his chest, and his shoulders looked stiff, as if he were bracing for something unknown.

The teacher smiled and said, “Class, this is Ben. He is new here.”

Mara looked at Ben again. He did not speak, but his eyes kept checking the floor and then the door, as if he wanted to escape the room without anyone noticing.

Mara thought of the empty seat beside her. It suddenly felt less empty and more like an invitation.''',
        question: QuestionModel(
          id: 'window-seat-q1',
          question: 'Why was Ben holding his notebook so tightly?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'A. Because he was angry with the teacher',
            'B. Because he wanted to hide the notebook from everyone',
            'C. Because he felt unsure and nervous in the new classroom',
          ],
          correctAnswerIndex: 2,
          hint: 'Look at his shoulders and the way he keeps checking the room.',
          encouragement:
              'Correct! Ben seemed nervous and unsure in the new classroom.',
          buddyHintParagraph:
              'He held his notebook close to his chest, and his shoulders looked stiff.',
        ),
      ),
      StorySegment(
        id: 'window-seat-2',
        content:
            '''During art time, the teacher passed out crayons. Ben only had a pencil and one short crayon in his bag. Mara noticed that he paused each time the class needed a color.

She remembered that she had a full box with several extra crayons. Instead of waiting for someone else to notice, she slid the box toward him and said, “You can borrow these.”

Ben looked surprised. Then he gave a small smile, the kind that appears when worry finally loosens its grip.

The classroom seemed brighter, even though nothing had changed on the walls.''',
        question: QuestionModel(
          id: 'window-seat-q2',
          question: 'What was the best next step for Mara?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'A. Share her crayons and speak kindly to Ben',
            'B. Tell Ben to sit somewhere else because he is new',
            'C. Ignore him so he can learn on his own',
          ],
          correctAnswerIndex: 0,
          hint: 'Think about what makes a new place feel safer.',
          encouragement:
              'Tama! Ang simpleng pagbabahagi ay malaking tulong sa bagong kaklase.',
          buddyHintParagraph:
              'She slid the box toward him and said, “You can borrow these.”',
        ),
      ),
      StorySegment(
        id: 'window-seat-3',
        content:
            '''By the end of the day, the class was working on a map poster that showed the places they came from. Ben drew a small river and a market from his old town. He finally spoke in a clear voice, adding one detail after another.

Mara noticed that once someone had offered him room, Ben had more room inside himself to speak.

When the teacher hung the poster on the wall, Mara realized that the brightest part of the room was not the window. It was the way one small welcome had helped a quiet student find his place.

She understood that kindness is often quiet at the beginning but can grow loud in the ways it changes a person’s day.''',
        question: QuestionModel(
          id: 'window-seat-q3',
          question: 'What did Mara learn at the end of the story?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'A. That new students never want help',
            'B. That posters are the most important part of class',
            'C. That small kindnesses can help someone feel safe and included',
          ],
          correctAnswerIndex: 2,
          hint: 'What changed after Mara shared her crayons?',
          encouragement:
              'Correct! Small kindnesses can help someone feel safe and welcome.',
          buddyHintParagraph:
              'The brightest part of the room was the way one small welcome had helped a quiet student find his place.',
        ),
      ),
    ],
  ),
  StoryModel(
    id: 'saturday-market-list',
    title: 'The Saturday Market List',
    author: 'KuwentoBuddy Original',
    coverImage:
        'assets/images/dragon_castle_fantasy_children_illustration_null_1773063135821.jpg',
    description:
        'Pinagkakatiwalaang bumili ni Jun ng mga pangangailangan sa palengke, at natutuhan niyang ang pagbabalik ng sobrang sukli ay bumubuo ng tiwala.',
    localizedTitles: {
      'fil': 'Ang Listahan sa Sabado',
    },
    level: StoryLevel.intermediate,
    categories: [StoryCategory.socialStories],
    estimatedMinutes: 6,
    language: 'en',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    sequenceActivity: [
      'Binigyan si Jun ng listahan at eksaktong pera.',
      'Napansin niya ang sobrang sukli sa palengke.',
      'Naaamoy niya ang mainit na pandesal at naisip ang baon.',
      'Ibinalik niya ang sobrang sukli at nakuha ang tiwala ng nanay niya.',
    ],
    segments: [
      StorySegment(
        id: 'market-list-opening',
        content: '''Page 1 (Opening Page)
Title: The Saturday Market List
Genre: Real-Life / Social Story
Level: Intermediate
Language: English
Synopsis:
Every Saturday, Jun helps his mother buy vegetables, rice, and soap at the market. This week, his mother gives him an exact amount of money and asks him to return with the change. At the market, Jun receives a little more money than he should. The extra coins seem small, but the decision they invite is bigger: keep them, or return them and protect the trust he has been given.
Source / Reference:
Original social story
Adapted for KuwentoBuddy
Heads Up:
May checkpoint questions after each part.

Read carefully and think before answering.

Best for guided decision-making.''',
      ),
      StorySegment(
        id: 'market-list-1',
        content:
            '''Jun folded the market list and slipped the exact money into his pocket. His mother reminded him, “The amount is just right. If there is change, bring it back.”

At the market, the seller weighed the tomatoes quickly and placed the coins in Jun’s hand. Jun looked down and noticed the change felt heavier than expected. He counted again and realized there was a little extra.

For a second, Jun simply stared. The coins were tiny, but his thoughts were not. He remembered how his mother had trusted him with the errand.

The market noise moved around him like a river, but Jun’s decision felt still.''',
        question: QuestionModel(
          id: 'market-list-q1',
          question: 'Why did Jun pause after receiving the change?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'A. Because he had forgotten the list at home',
            'B. Because he planned to spend the money right away',
            'C. Because he noticed the amount might not belong to him',
          ],
          correctAnswerIndex: 2,
          hint: 'Think about what he remembered from his mother’s instruction.',
          encouragement:
              'Correct! Jun realized the extra money might not be his to keep.',
          buddyHintParagraph:
              'The amount is just right. If there is change, bring it back.',
        ),
      ),
      StorySegment(
        id: 'market-list-2',
        content:
            '''As Jun walked past a stall selling warm bread, the smell made his stomach growl. He thought about the sweet bun he had wanted for days. With the extra coins, he could buy one and still go home with enough to make the errand feel easier.

Then he looked at the seller, who was busy serving another customer. The man’s hands moved fast, and Jun realized the mistake may have happened without anyone noticing.

Jun took a slow breath. He placed the extra coins back into his palm and turned toward the stall.

“Nanghingi po ako ng sobra,” he said.

The seller blinked, then smiled with relief.''',
        question: QuestionModel(
          id: 'market-list-q2',
          question: 'What should Jun do next?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.emotion,
          options: [
            'A. Return the extra money to the seller',
            'B. Spend part of it on the bread stall',
            'C. Keep the coins and say nothing',
          ],
          correctAnswerIndex: 0,
          hint: 'Think about trust, not just desire.',
          encouragement:
              'Tama! Ang pagbalik ng sobrang sukli ay pagprotekta sa tiwala.',
          buddyHintParagraph:
              'He placed the extra coins back into his palm and turned toward the stall.',
        ),
      ),
      StorySegment(
        id: 'market-list-3',
        content:
            '''When Jun reached home, he handed his mother the vegetables, the soap, and the exact change. He also told her about the extra coins and how he returned them.

His mother listened quietly, then nodded. “You made the errand smaller in money, but bigger in honesty,” she said.

Jun felt the warm bread smell still lingering in the air, but now it did not tempt him as much. The part that stayed with him was his mother’s calm smile.

He learned that trust grows when a person returns even the little things that could have been hidden.''',
        question: QuestionModel(
          id: 'market-list-q3',
          question: 'What lesson did Jun learn from the errand?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'A. That honesty builds trust even in small tasks',
            'B. That market trips are only about buying snacks',
            'C. That it is better to ignore mistakes if nobody notices',
          ],
          correctAnswerIndex: 0,
          hint: 'Listen to what his mother says about honesty.',
          encouragement:
              'Correct! Honesty made the task matter more than the coins.',
          buddyHintParagraph:
              'You made the errand smaller in money, but bigger in honesty.',
        ),
      ),
    ],
  ),
];

final List<StoryModel> adventureJourneyData = [
  // STORY 1 - BEGINNER
  StoryModel(
    id: 'alice-strange-land',
    title: 'The Journey of Alice in the Strange Land',
    author: 'Lewis Carroll / KuwentoBuddy Adaptation',
    coverImage:
        'assets/images/magical_forest_fairy_tale_children_book_illustration_null_1773063134827.jpg',
    description:
        'A simplified public domain adventure story about Alice entering a strange world, learning to think carefully, make smart decisions, and stay brave.',
    level: StoryLevel.beginner,
    categories: [StoryCategory.adventureJourney],
    estimatedMinutes: 5,
    language: 'en',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    sequenceActivity: [
      'Alice saw a white rabbit wearing a coat.',
      'She followed the rabbit into a hole.',
      'She fell into a strange tunnel.',
      'She landed in a room with many locked doors.',
      'She tried to find a way to enter the small door leading to a garden.',
    ],
    segments: [
      StorySegment(
        id: 'alice-opening',
        content: '''Page 1 (Opening Page)
Title: The Journey of Alice in the Strange Land
Genre: Adventure & Journey Stories
Level: Beginner
Language: English
Synopsis:
This is a simplified adaptation of a classic public domain adventure story. It follows a curious girl named Alice who unexpectedly enters a strange and unfamiliar world filled with unusual creatures, mysterious objects, and surprising events. As she explores this new place, she slowly learns the importance of thinking carefully before acting, making smart decisions, and staying brave even when everything feels confusing.
Source / Reference:
Adapted from Alice’s Adventures in Wonderland by Lewis Carroll—Public Domain
Adapted for KuwentoBuddy
Heads Up:
This story has checkpoint questions after each part.

Read carefully and think before answering.

Best for guided introduction''',
      ),
      StorySegment(
        id: 'alice-1',
        content:
            '''One quiet afternoon, a young girl named Alice was sitting by the riverbank, watching the gentle flow of water and the clouds above. She felt bored because nothing interesting seemed to be happening around her. She was about to close her eyes when something unusual caught her attention.

A white rabbit wearing a neat coat was running nearby. It was holding a pocket watch and looking very worried.

“What a strange rabbit,” Alice said softly to herself, her curiosity immediately growing.

To her surprise, the rabbit suddenly spoke in a hurried voice, “Oh dear! Oh dear! I’m going to be late!”

Because she was very curious, Alice stood up and decided to follow it. The rabbit ran fast and disappeared into a large hole at the base of a tree.

Without hesitation, Alice followed the rabbit into the hole.''',
        question: QuestionModel(
          id: 'alice-q1',
          question: 'Why did Alice follow the rabbit?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'Because she was curious about the strange rabbit',
            'Because she was told to go into the hole',
            'Because she was running away from home',
          ],
          correctAnswerIndex: 0,
          hint: 'What did Alice feel when she saw something unusual?',
          encouragement: 'Correct! Alice followed because she was curious.',
          buddyHintParagraph:
              'Because she was very curious, Alice stood up and decided to follow it.',
        ),
      ),
      StorySegment(
        id: 'alice-2',
        content:
            '''As soon as Alice entered the hole, she began falling down a long, deep tunnel. She carefully looked around while falling and noticed strange things along the walls—shelves, books, and small doors passing by slowly as she went deeper and deeper.

The fall felt long, but she was not hurt. Instead, she felt amazed by everything she was seeing.

Finally, she landed safely in a quiet room. The room was very strange and unfamiliar, filled with many locked doors of different sizes. The place felt magical but also confusing.

“This place is very unusual,” Alice whispered, looking around carefully.

She felt both curious and unsure about what would happen next.''',
        question: QuestionModel(
          id: 'alice-q2',
          question:
              'How did Alice most likely feel after landing in the strange place?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.emotion,
          options: [
            'She felt confused but excited',
            'She felt angry and wanted to leave immediately',
            'She felt sleepy and ignored everything',
          ],
          correctAnswerIndex: 0,
          hint: 'Think about arriving in a completely unknown world.',
          encouragement: 'Great job! She felt both confusion and excitement.',
          buddyHintParagraph:
              'She felt both curious and unsure about what would happen next.',
        ),
      ),
      StorySegment(
        id: 'alice-3',
        content:
            '''While exploring the room, Alice found a small golden key lying on a table. She became excited and tried to see what it could open. She walked around and tried opening every door she could find, but most of them were either locked or too small for her to pass through.

After searching carefully, she noticed a very tiny door hidden in one corner of the room. Behind it, she could see a beautiful garden filled with bright colors, flowers, and sunlight.

“I want to go there,” Alice said with hope in her voice.

However, when she tried to enter, she realized she was too big to fit through the door. She stepped back and looked at it again, thinking carefully about how she could solve this problem.''',
        question: QuestionModel(
          id: 'alice-q3',
          question: 'What will Alice most likely do next?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.prediction,
          options: [
            'She will try to find a way to become small enough to enter the door',
            'She will leave the room and go back home immediately',
            'She will ignore the garden and sleep',
          ],
          correctAnswerIndex: 0,
          hint: 'What is stopping her from entering the garden?',
          encouragement:
              'Correct! She will likely try to find a way to fit through.',
          buddyHintParagraph:
              'She stepped back and looked at it again, thinking carefully about how she could solve this problem.',
        ),
      ),
      StorySegment(
        id: 'alice-4',
        content:
            '''Alice continued to explore the strange world around her instead of giving up. Even though she felt confused at times and some things did not always make sense, she stayed curious and kept trying to understand her surroundings.

Every new place she discovered taught her something important. She learned that in unfamiliar situations, it is important to stay calm, observe carefully, and think before making decisions.''',
        question: QuestionModel(
          id: 'alice-q4',
          question: 'Why did Alice continue exploring?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'Because she was curious and wanted to understand the strange world',
            'Because she was forced to stay there',
            'Because she had nowhere else to go',
          ],
          correctAnswerIndex: 0,
          hint: 'Think about what motivated her from the beginning.',
          encouragement: 'Excellent! Her curiosity kept her going.',
          buddyHintParagraph:
              'Alice continued to explore the strange world around her instead of giving up.',
        ),
      ),
    ],
  ),

  // STORY 2 - INTERMEDIATE
  StoryModel(
    id: 'lost-compass-lisbon',
    title: 'The Lost Compass of Lisbon',
    author: 'Public Domain Adventure Tradition / KuwentoBuddy Adaptation',
    coverImage:
        'assets/images/underwater_ocean_mermaid_children_story_null_1773063136715.png',
    description:
        'A young apprentice sailor named Elias discovers an unusual compass and must use it to survive a dangerous sea journey and uncover hidden truths.',
    localizedTitles: {
      'fil': 'Ang Nawawalang Kompas ng Lisbon',
    },
    level: StoryLevel.intermediate,
    categories: [StoryCategory.adventureJourney],
    estimatedMinutes: 6,
    language: 'en',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    sequenceActivity: [
      'Elias receives a mysterious compass from his father before his journey.',
      'Elias joins a trading ship in Lisbon.',
      'A storm destroys the ship’s direction.',
      'Elias uses the compass to guide the ship safely.',
      'The crew reaches a strange, unknown island.',
      'Elias discovers ancient carvings and a hidden lighthouse.',
      'He realizes the compass leads to unfinished mysteries of the sea.',
    ],
    segments: [
      StorySegment(
        id: 'lisbon-opening',
        content: '''Page 1 (Opening Page)
Title: The Lost Compass of Lisbon
Genre: Adventure & Journey Story
Level: Intermediate
Language: English
Synopsis:
A young apprentice sailor named Elias discovers an old compass that once belonged to a legendary explorer. When a sudden storm destroys his ship’s route, Elias must rely on the mysterious compass to survive a dangerous journey across unfamiliar seas. Along the way, he learns that courage is not about fearlessness—but about continuing even when hope is uncertain.
Source / Reference:
Inspired by global Public Domain Adventure Literature (sea exploration tradition)
Adapted for KuwentoBuddy
Heads Up:
This story has checkpoint questions after each part.

Read carefully and think before answering.

Best for guided decision-making''',
      ),
      StorySegment(
        id: 'lisbon-1',
        content:
            '''Elias had always dreamed of becoming a great sailor like his father, who once crossed the Atlantic Ocean and went missing at sea. At just sixteen, he joined a trading ship leaving Lisbon, carrying nothing but a small bag and an old brass compass given by his father before he disappeared.

The crew often laughed at him, saying he was too young to understand the sea. But Elias never responded. Instead, he carefully studied the compass every night, noticing something strange—it did not always point north. Sometimes, it shifted slightly, as if reacting to something it could not see.

One evening, dark clouds gathered faster than expected. The sea turned violent, and the ship lost its direction completely.

“Hold tight!” the captain shouted. “We are off course!”

Elias looked at his compass. It was spinning slowly, then suddenly stopped—pointing toward a direction no map had marked.''',
        question: QuestionModel(
          id: 'lisbon-q1',
          question:
              'Why did Elias trust the compass even though it behaved strangely?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'He believed the compass was broken and ignored it.',
            'He thought it had no importance on the journey.',
            'He believed it had a special connection to guiding him safely.',
          ],
          correctAnswerIndex: 2,
          hint: 'Think about why Elias kept studying it every night.',
          encouragement:
              'Correct! Elias trusted the compass because he believed it had meaning beyond a normal tool.',
          buddyHintParagraph:
              'He carefully studied the compass every night, noticing something strange.',
        ),
      ),
      StorySegment(
        id: 'lisbon-2',
        content:
            '''The captain ordered the crew to follow Elias’s direction, even though many doubted him. As they changed course, the storm intensified. Waves rose very high above the ship, crashing against it.

Elias felt fear rising in his chest. His hands shook slightly as he held the compass tightly.

“I hope this is the right way...” he whispered.

But deep inside, something told him to continue.

Hours passed. The storm slowly weakened, and the sea began to calm. When morning came, the crew found themselves near a strange island that did not appear on any map.

The captain looked at Elias with shock. “You... may have just saved us.”''',
        question: QuestionModel(
          id: 'lisbon-q2',
          question:
              'How did Elias feel while guiding the ship through the storm?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.emotion,
          options: [
            'He felt afraid but determined to continue.',
            'He felt completely confident and unafraid.',
            'He felt angry at the crew for doubting him.',
          ],
          correctAnswerIndex: 0,
          hint: 'Look at his reaction during the storm.',
          encouragement:
              'Correct! Elias felt fear, but he did not stop trying.',
          buddyHintParagraph:
              'His hands shook slightly as he held the compass tightly.',
        ),
      ),
      StorySegment(
        id: 'lisbon-3',
        content:
            '''The island was covered in dense forests and strange ruins. The crew decided to explore while repairing the ship. Elias, still holding the compass, noticed something unusual—the needle no longer spun randomly. It now pointed steadily toward the center of the island.

Curious, Elias followed it alone.

As he walked deeper into the forest, he found ancient carvings showing ships, storms, and a glowing compass identical to his own. Beneath it was a warning carved into stone:

“Those who follow the compass must choose between staying safe or discovering the truth.”

Elias paused. The wind grew colder.''',
        question: QuestionModel(
          id: 'lisbon-q3',
          question: 'What is most likely to happen next?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.prediction,
          options: [
            'Elias will abandon the compass and return to the ship immediately.',
            'Elias will continue following the compass to discover its mystery.',
            'The crew will leave the island without exploring further.',
          ],
          correctAnswerIndex: 1,
          hint: 'Think about Elias’s curiosity and bravery.',
          encouragement:
              'Great thinking! Elias is likely to continue because he wants to understand the truth.',
          buddyHintParagraph:
              'The needle no longer spun randomly. It now pointed steadily toward the center of the island.',
        ),
      ),
      StorySegment(
        id: 'lisbon-4',
        content:
            '''Elias chose to follow the compass deeper into the island. At its center, he discovered an old lighthouse still faintly glowing, even though no fire burned inside it.

Inside, he found records of explorers who had vanished at sea—including explorers connected to his father’s journey. The compass was not just a tool; it was a guide left behind to lead lost sailors toward unfinished journeys.

Elias realized something important: the sea did not only take people away, it also led some people to discover its secrets.

He stood quietly, knowing his journey had only just begun.''',
        question: QuestionModel(
          id: 'lisbon-q4',
          question: 'Why was the compass important in Elias’s journey?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'It was just a normal navigation tool.',
            'It guided him toward discovering hidden truths about lost sailors.',
            'It was only useful during storms.',
          ],
          correctAnswerIndex: 1,
          hint: 'Think about what Elias discovered on the island.',
          encouragement:
              'Correct! The compass led him to uncover deeper truths, not just directions.',
          buddyHintParagraph:
              'Inside, he found records of explorers who had vanished at sea.',
        ),
      ),
    ],
  ),

  // STORY 3 - ADVANCED
  StoryModel(
    id: 'silent-ship-arctic-night',
    title: 'The Silent Ship of the Arctic Night',
    author: 'Public Domain Exploration Tradition / KuwentoBuddy Adaptation',
    coverImage:
        'assets/images/dragon_castle_fantasy_children_illustration_null_1773063135821.jpg',
    description:
        'A scientific Arctic expedition encounters a magnetic storm, psychological strain, and a hidden structure beneath the ice that changes the meaning of the mission.',
    level: StoryLevel.advanced,
    categories: [StoryCategory.adventureJourney],
    estimatedMinutes: 8,
    language: 'en',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    sequenceActivity: [
      'Dr. Adrian Wells leads a scientific Arctic expedition.',
      'A magnetic storm disrupts all navigation systems.',
      'The ship becomes stranded in uncharted ice waters.',
      'The compass begins behaving abnormally.',
      'Crew members experience increasing psychological strain and confusion.',
      'The ice beneath the ship begins to fracture.',
      'The crew follows the compass across unstable ice.',
      'They discover a massive structure beneath the ice.',
      'The compass stops and synchronizes with the structure.',
      'Adrian realizes the expedition has uncovered a recurring unknown phenomenon.',
    ],
    segments: [
      StorySegment(
        id: 'arctic-opening',
        content: '''Page 1 (Opening Page)
Title: The Silent Ship of the Arctic Night
Genre: Adventure & Journey Story
Level: Advanced
Language: English
Synopsis:
In the frozen Arctic waters, a scientific expedition led by Dr. Adrian Wells enters one of the most isolated regions on Earth to study unusual disruptions in the planet’s magnetic field. What begins as a controlled research mission slowly turns into a change in how time feels during isolation, and mental stress and emotional strain after a violent magnetic storm destroys all navigation systems.

Cut off from communication, the crew drifts into an uncharted ice field where maps no longer apply and instruments lose meaning. As survival becomes uncertain, the expedition shifts into something deeper—an exploration of fear, human limits, and the unknown intelligence hidden beneath the Arctic ice.
Source / Reference:
Inspired by Public Domain Exploration and Arctic Expedition Narratives (19th—early 20th century literature tradition)
Adapted for KuwentoBuddy
Heads Up:
This story contains complex emotions, survival ethics, and psychological tension.

Read carefully and analyze motivations, emotional shifts, and consequences.

Best for guided learning and deeper reflection.''',
      ),
      StorySegment(
        id: 'arctic-1',
        content:
            '''The expedition began with strict scientific discipline and careful optimism. Dr. Adrian Wells, a respected polar researcher known for surviving two previous Arctic missions, led a six-member international team into the Arctic Circle. Their objective was to document unusual fluctuations in the Earth’s magnetic field that satellite data could not fully explain.

For several weeks, the mission followed perfect order. Daily readings were recorded, ice movements were tracked, and the crew operated with precision despite extreme cold and constant darkness.

Then the storm came.

It did not arrive like ordinary weather. Instead, it began with silence—radios losing frequency, compasses twitching without reason, and digital systems flickering into error. Within minutes, a magnetic disturbance overwhelmed all instruments. The ship lost orientation completely and drifted beyond any recorded map.

“We are blind,” one crew member said quietly, his voice trembling more than the ship itself.

Adrian stood alone on the frozen outer deck, gripping a brass compass that no longer obeyed north. Instead, its needle shook violently before slowly stabilizing—pointing downward, toward the thick Arctic ice beneath them, as if something below the ice was affecting it.

He did not speak. But he did not turn away either.''',
        question: QuestionModel(
          id: 'arctic-q1',
          question:
              'Why did Dr. Adrian continue observing the broken compass instead of discarding it?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'He believed the anomaly might reveal a deeper scientific phenomenon.',
            'He thought the compass was completely useless and ignored it.',
            'He wanted to avoid responsibility for navigation.',
          ],
          correctAnswerIndex: 0,
          hint: 'Think about his role as a scientist, not just a survivor.',
          encouragement:
              'Correct! Adrian’s scientific mindset made him consider that the anomaly had meaning.',
          buddyHintParagraph:
              'Instead, its needle shook violently before slowly stabilizing—pointing downward.',
        ),
      ),
      StorySegment(
        id: 'arctic-2',
        content:
            '''Days turned into an indistinguishable stretch of darkness. In the Arctic night, the absence of sunlight distorted all sense of time. The ship became a sealed world of cold metal, weak light, and growing psychological strain. Supplies were carefully rationed, but morale weakened faster than provisions.

Arguments began quietly at first—about direction, responsibility, and trust. Soon, they escalated into open disagreement. Some crew members demanded they abandon the ship and attempt a dangerous walk across unstable ice toward uncertain land. Others insisted that leaving the ship meant certain death.

Adrian, however, remained fixated on the compass. It no longer behaved randomly. Instead, it pulsed faintly at irregular intervals, as if responding to something deep beneath the ice.

Then, on the eleventh night, a crew member collapsed in the corridor. There were no physical injuries. Only extreme exhaustion, confusion, and fear.

“We feel like something is watching us, even though we cannot see anything,” he whispered hoarsely before losing consciousness.

Adrian stood beside him for a long moment. For the first time since the expedition began, he felt something he could not classify—doubt, not of science, but of reality itself.''',
        question: QuestionModel(
          id: 'arctic-q2',
          question:
              'What emotional state best describes Dr. Adrian during this stage?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.emotion,
          options: [
            'He feels burdened by responsibility and uncertain about his decisions.',
            'He feels completely confident and unaffected by pressure.',
            'He feels indifferent and detached from the crew’s suffering.',
          ],
          correctAnswerIndex: 0,
          hint: 'Consider the collapse of order and rising tension.',
          encouragement:
              'Correct! Adrian is carrying emotional weight and uncertainty.',
          buddyHintParagraph:
              'For the first time since the expedition began, he felt something he could not classify.',
        ),
      ),
      StorySegment(
        id: 'arctic-3',
        content:
            '''On the seventh night following the storm, the Arctic ice began to shift in unnatural ways. Deep cracks formed beneath the ship, producing low, rhythmic vibrations that echoed through the hull like distant machinery awakening.

At that exact moment, the compass changed.

It stopped trembling.

It stabilized completely.

And it pointed directly downward with absolute certainty.

Adrian made a decision that would define the fate of the expedition.

“We move now,” he ordered.

The crew hesitated, torn between fear and obedience, but ultimately followed. They abandoned the ship, stepping onto unstable ice illuminated only by faint green auroras stretching across the sky.

The journey across the frozen terrain was brutal. Every step risked collapse into dark water beneath the ice. Hours passed under suffocating silence until the landscape itself began to change.

Then they saw it.

Beneath the translucent ice layer lay something massive—an artificial metallic structure, far larger than any known human construction, embedded deep within the frozen ocean floor. It emitted a faint, rhythmic pulse.

And it was active.''',
        question: QuestionModel(
          id: 'arctic-q3',
          question: 'What is most likely to happen next?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.prediction,
          options: [
            'The crew will immediately return to the ship and ignore the structure.',
            'The crew will investigate the unknown structure beneath the ice.',
            'The ice will completely melt and end the expedition.',
          ],
          correctAnswerIndex: 1,
          hint: 'Think about human curiosity in extreme discoveries.',
          encouragement:
              'Correct! The discovery strongly suggests further exploration.',
          buddyHintParagraph:
              'Beneath the translucent ice layer lay something massive.',
        ),
      ),
      StorySegment(
        id: 'arctic-4',
        content:
            '''As the crew approached the structure, an unsettling silence spread across the ice. Even the wind seemed to fade, as if the environment itself was listening. The compass in Adrian’s hand suddenly stopped functioning altogether.

Then, instead of silence, it began to vibrate—matching a steady rhythm coming from the structure beneath the ice.

Adrian realized something that shattered the original purpose of their mission.

They were not the first.

Carvings and repeated structural patterns suggested multiple expeditions across centuries—each one encountering the same anomaly, expeditions that never returned or were never recorded again.

This was not a random discovery. It was repetition.

A cycle.

The expedition was no longer about navigation or survival.

It raised a question: were they guided here, or was it just a coincidence?

Adrian stood motionless, understanding that turning back was no longer a question of direction.

It was a question of consequence.''',
        question: QuestionModel(
          id: 'arctic-q4',
          question: 'Why is the Arctic structure significant to the story?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'It is just a natural ice formation.',
            'It suggests a hidden, repeated history of lost expeditions and unknown forces.',
            'It is only important for weather observation.',
          ],
          correctAnswerIndex: 1,
          hint: 'Think about the markings and past disappearances.',
          encouragement:
              'Correct! The structure implies a deeper, mysterious pattern.',
          buddyHintParagraph:
              'Carvings and repeated structural patterns suggested multiple expeditions across centuries.',
        ),
      ),
    ],
  ),
];

final List<StoryModel> socialStoriesData = [
  StoryModel(
    id: 'helpful-town-day',
    title: 'A Day in the Helpful Town',
    author: 'Public Domain Moral Story Tradition / KuwentoBuddy Adaptation',
    coverImage:
        'assets/images/rice_terraces_Philippines_landscape_beautiful_null_1773063138652.jpg',
    description:
        'A kind young boy named Oliver learns how small acts of kindness, sharing, and listening can make a big difference in his community.',
    localizedTitles: {
      'fil': 'Isang Araw sa Matulunging Bayan',
    },
    level: StoryLevel.beginner,
    categories: [StoryCategory.socialStories],
    estimatedMinutes: 5,
    language: 'en',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    sequenceActivity: [
      'Oliver walked to the market in the morning.',
      'Oliver helped an elderly woman carry her basket.',
      'Oliver saw a hungry child outside the bakery.',
      'Oliver shared the bread money with the child.',
      'Oliver returned home feeling happy and fulfilled.',
    ],
    segments: [
      StorySegment(
        id: 'helpful-town-day-opening',
        content: '''Page 1 (Opening Page)
Title: A Day in the Helpful Town
Genre: Real-Life / Social Story
Level: Beginner
Language: English
Synopsis:
This is a simplified adaptation inspired by classic public domain moral and educational storytelling traditions. It follows a kind young boy named Oliver who learns how small acts of kindness—like helping others, sharing, and listening—can make a big difference in his community. As he goes through his day, he discovers the importance of being responsible, polite, and considerate to others in everyday life.
Source / Reference:
Inspired by Public Domain Moral and Educational Stories (traditional fable literature)
Adapted for KuwentoBuddy
Heads Up:
This story includes checkpoint questions after each section.

Think carefully before answering to earn points (0–3).

Best for guided introduction''',
      ),
      StorySegment(
        id: 'helpful-town-day-1',
        content:
            '''In a small and peaceful town, there was a young boy named Oliver who lived with his grandmother. Every morning, he would walk to the nearby market to buy fresh bread and help his grandmother prepare breakfast.

One morning, Oliver noticed an elderly woman struggling to carry her basket of fruits. She looked tired and was walking very slowly.

Oliver paused for a moment. He remembered what his grandmother always said: “Kindness is shown in small actions.”

Without hesitation, he walked up to her, offered help, and said, “May I help you carry your basket?”

The woman smiled warmly and nodded.''',
        question: QuestionModel(
          id: 'helpful-town-day-q1',
          question: 'Why did Oliver help the elderly woman?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'He wanted to impress other people at the market.',
            'He believed it was the right and kind thing to do.',
            'He was told by someone to help her.',
          ],
          correctAnswerIndex: 1,
          hint: 'Think about what Oliver learned from his grandmother.',
          encouragement:
              'Correct! Oliver helped because he understood kindness and responsibility.',
          buddyHintParagraph: 'Kindness is shown in small actions.',
        ),
      ),
      StorySegment(
        id: 'helpful-town-day-2',
        content:
            '''As Oliver carried the basket, the woman thanked him many times. Her voice sounded soft but full of gratitude. People in the market began to notice Oliver’s action.

Some smiled at him, while others quietly nodded in approval.

Oliver felt something warm inside his chest—a feeling of happiness and pride. It was not money or reward—but something better. He felt proud of doing something good without being asked.

When he finally returned the basket, the woman gently said, “You have a kind heart, young boy.”

Oliver smiled, feeling happy and calm.''',
        question: QuestionModel(
          id: 'helpful-town-day-q2',
          question: 'How did Oliver feel after helping the woman?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.emotion,
          options: [
            'He felt proud and happy because he did something good.',
            'He felt angry because it was difficult work.',
            'He felt bored and wanted to leave quickly.',
          ],
          correctAnswerIndex: 0,
          hint: 'Think about his reaction after returning the basket.',
          encouragement: 'Correct! Oliver felt a sense of pride and happiness.',
          buddyHintParagraph:
              'He felt proud of doing something good without being asked.',
        ),
      ),
      StorySegment(
        id: 'helpful-town-day-3',
        content:
            '''Later that day, Oliver walked past a small bakery. He saw a younger child standing outside, looking at the bread inside with hungry eyes.

The child looked unsure and shy, as if afraid to ask for help.

Oliver stopped again. He looked at his own small coin purse. He only had enough money for one loaf of bread—for his grandmother.

He thought carefully.

“If I help this child, I might not have enough for home… but maybe I can still find a way to help both,” he whispered to himself.

But then he remembered how it felt when someone helped him before.''',
        question: QuestionModel(
          id: 'helpful-town-day-q3',
          question: 'What will Oliver most likely do next?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.prediction,
          options: [
            'He will decide to help the hungry child.',
            'He will ignore the child and walk away.',
            'He will buy extra toys instead.',
          ],
          correctAnswerIndex: 0,
          hint: 'Think about Oliver’s previous actions.',
          encouragement: 'Correct! Oliver is likely to choose kindness again.',
          buddyHintParagraph: 'He thought carefully.',
        ),
      ),
      StorySegment(
        id: 'helpful-town-day-4',
        content:
            '''Oliver gently approached the child and asked what was wrong. After hearing the child’s situation, he decided to share part of his own money to buy a small loaf of bread.

The child smiled happily and thanked him before running home.

That evening, Oliver returned home with enough food, after carefully sharing what he had, but his heart felt full.

His grandmother noticed his calm smile and asked, “Did something good happen today?”

Oliver simply nodded and said, “Yes, Grandma. I learned something important today.” He explained everything honestly to his grandmother.''',
        question: QuestionModel(
          id: 'helpful-town-day-q4',
          question: 'Why did Oliver feel happy even though he had less food?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'He forgot about his responsibility at home.',
            'He felt happy because he helped others and did something meaningful.',
            'He was unhappy and tried to hide it.',
          ],
          correctAnswerIndex: 1,
          hint: 'Think about what gave Oliver satisfaction.',
          encouragement: 'Correct! Helping others made him feel fulfilled.',
          buddyHintParagraph:
              'He felt proud of doing something good without being asked.',
        ),
      ),
    ],
  ),
  StoryModel(
    id: 'maya-missing-wallet',
    title: 'The Day Maya Handled the Missing Wallet',
    author: 'Public Domain Moral Story Tradition / KuwentoBuddy Adaptation',
    coverImage:
        'assets/images/dragon_castle_fantasy_children_illustration_null_1773063135821.jpg',
    description:
        'Maya finds a lost wallet on the bus and must decide what to do with it, learning about honesty and responsibility.',
    localizedTitles: {
      'fil': 'Ang Araw na Hinarap ni Maya ang Nawawalang Pitaka',
    },
    level: StoryLevel.intermediate,
    categories: [StoryCategory.socialStories],
    estimatedMinutes: 6,
    language: 'en',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    sequenceActivity: [
      'Maya boards the bus after school',
      'She notices a wallet left on a seat',
      'She opens the wallet and sees the ID card',
      'She feels unsure about what to do',
      'She considers her choices as her stop approaches',
      'She walks toward the bus driver',
      'She reports the wallet to the bus driver, and it is returned to the owner',
    ],
    segments: [
      StorySegment(
        id: 'maya-missing-wallet-opening',
        content: '''Page 1 (Opening Page)
Title: The Day Maya Handled the Missing Wallet
Genre: Real-Life / Social Story
Level: Intermediate
Language: English
Synopsis:
Maya is a student who takes the public bus every day after school. One afternoon, she finds a wallet left on the seat beside her. Inside are money, ID cards, and receipts. As the bus continues its route and passengers come and go, Maya is suddenly placed in a situation where she must decide what to do with something that does not belong to her. Her decision will reflect her understanding of honesty, responsibility, and doing the right thing even when no one is directly watching.
Source / Reference:
Inspired by public domain moral storytelling traditions (everyday ethics / civic responsibility narratives)
Adapted for KuwentoBuddy
Heads Up:
This story has checkpoint questions after each part.

Read carefully and think before answering.

Best for guided decision-making''',
      ),
      StorySegment(
        id: 'maya-missing-wallet-1',
        content:
            '''Maya finished her last class feeling exhausted but relieved that the school day was finally over. She boarded her usual public bus and sat near the window, putting on her earphones while watching the streets slowly pass by. At first, the ride was calm, and she was simply thinking about going home and resting.

After a few stops, a man sitting nearby suddenly stood up in a rush because he had reached his destination. He quickly stepped off the bus without checking his seat carefully. In the middle of his movement, he accidentally left behind a small brown wallet.

Maya noticed it right away after the man got off. For a moment, she just stared at it while the bus doors closed and the vehicle continued moving forward. No one else seemed aware of what had just happened.

She slowly picked up the wallet. It felt heavier than she thought, and that feeling made her pause. She started thinking carefully about what she should do next.''',
        question: QuestionModel(
          id: 'maya-missing-wallet-q1',
          question: 'Why did Maya hesitate after picking up the wallet?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'Because she was unsure about the correct and honest action to take',
            'Because she wanted to immediately spend the money inside',
            'Because she planned to get off the bus early',
          ],
          correctAnswerIndex: 0,
          hint: 'Think about responsibility and doing what is right.',
          encouragement: 'Correct! Maya was unsure what the right action was.',
          buddyHintParagraph:
              'She started thinking carefully about what she should do next.',
        ),
      ),
      StorySegment(
        id: 'maya-missing-wallet-2',
        content:
            '''Maya opened the wallet slightly, just enough to see what was inside. She found an ID card, a small amount of cash, and a student identification card that showed the owner was a young college student. Seeing the photo made her realize this wallet definitely belonged to someone who would be worried about losing it.

Her stop was getting closer, and she could feel time passing quickly. She started feeling nervous because she did not know what decision to make before she needed to leave the bus. One part of her thought it would be easier to just ignore the wallet and walk away. But she also felt it would not be right.

An elderly woman sitting a few seats away noticed Maya’s behavior. She gently said, “That looks like something very important to someone.”

Maya nodded slightly but did not speak. She tightened her grip on the wallet, feeling confused and worried as she tried to figure out what to do.''',
        question: QuestionModel(
          id: 'maya-missing-wallet-q2',
          question: 'How did Maya most likely feel at this moment?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.emotion,
          options: [
            'Confused and pressured because she had to decide quickly',
            'Completely calm and relaxed as if nothing mattered',
            'Angry at the passenger who lost the wallet',
          ],
          correctAnswerIndex: 0,
          hint: 'Think about time pressure and responsibility.',
          encouragement: 'Correct! Maya felt confused and pressured.',
          buddyHintParagraph:
              'She tightened her grip on the wallet, feeling confused and worried as she tried to figure out what to do.',
        ),
      ),
      StorySegment(
        id: 'maya-missing-wallet-3',
        content:
            '''As the bus continued forward, it began slowing down as it approached Maya’s stop. She realized she had only a short amount of time left to make a decision. Her thoughts became even more intense as she weighed her choices carefully.

She considered what she could do: she could keep the wallet and leave quietly, or she could report it to the bus driver before getting off. She also remembered what her teacher once said in class about honesty—that doing the right thing matters even when no one is watching.

Maya slowly stood up while still holding the wallet. She felt nervous but decided to act, and she made her way toward the front of the bus where the driver was seated.''',
        question: QuestionModel(
          id: 'maya-missing-wallet-q3',
          question: 'What will Maya most likely do next?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.prediction,
          options: [
            'She will inform the bus driver about the lost wallet',
            'She will hide the wallet in her bag and leave the bus',
            'She will throw the wallet outside the window',
          ],
          correctAnswerIndex: 0,
          hint: 'Think about her moral thoughts and actions.',
          encouragement: 'Correct! She is likely to report it.',
          buddyHintParagraph:
              'She slowly stood up while still holding the wallet.',
        ),
      ),
      StorySegment(
        id: 'maya-missing-wallet-4',
        content:
            '''Maya reached the front of the bus and handed the wallet to the driver. She calmly explained what happened and where she found it. The driver nodded and thanked her for being honest. He announced that they would try to return it to the rightful owner at the next stop.

When Maya finally got off the bus, she felt a sense of relief. She had not gained anything material, but she felt that she had done something meaningful. The decision she made made her feel more responsible and confident in her values.

That evening, a message was sent through the school group chat. The wallet had been successfully returned, and the owner expressed deep gratitude for the person who handed it in.''',
        question: QuestionModel(
          id: 'maya-missing-wallet-q4',
          question: 'Why did Maya feel relieved after returning the wallet?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'Because she felt satisfied knowing she acted honestly and correctly',
            'Because she received a reward for returning it',
            'Because she avoided getting punished',
          ],
          correctAnswerIndex: 0,
          hint: 'Think about moral satisfaction and honesty.',
          encouragement:
              'Correct! She felt good because she did the right thing.',
          buddyHintParagraph:
              'She had not gained anything material, but she felt that she had done something meaningful.',
        ),
      ),
    ],
  ),
  StoryModel(
    id: 'ethics-protocol-raven-station',
    title: 'The Ethics Protocol of Raven Station',
    author: 'Public Domain Science Ethics Tradition / KuwentoBuddy Adaptation',
    coverImage:
        'assets/images/underwater_ocean_mermaid_children_story_null_1773063136715.png',
    description:
        'At a deep-space research station orbiting Europa, Dr. Elara Vance must decide how to respond when a signal beneath the ice may be either the greatest discovery in human history or a dangerous unknown.',
    localizedTitles: {
      'fil': 'Ang Protokol sa Etika ng Raven Station',
    },
    level: StoryLevel.advanced,
    categories: [StoryCategory.socialStories],
    estimatedMinutes: 8,
    language: 'en',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    sequenceActivity: [
      'Dr. Elara Vance leads the Raven Station mission around Europa',
      'The drilling system detects structured signals beneath the ice',
      'The crew notices unusual effects and changes in the station',
      'A debate arises between shutdown and continued study',
      'The signal begins predicting human research patterns',
      'Station systems temporarily synchronize with the anomaly',
      'Dr. Elara authorizes controlled communication',
      'The signal begins adapting faster to human responses',
      'A full structural replication of Raven Station is transmitted',
      'Elara realizes the intelligence is learning from human actions',
    ],
    segments: [
      StorySegment(
        id: 'raven-station-opening',
        content: '''Page 1 (Opening Page)
Title: The Ethics Protocol of Raven Station
Genre: Real-Life / Social Story (Scientific Ethics & Crisis Decision-Making)
Level: Advanced
Language: English
Synopsis:
At Raven Station, a remote deep-space research facility orbiting Jupiter’s moon Europa, a multidisciplinary team studies microbial life beneath the frozen surface. During a routine drilling operation, the station detects an unusual signal pattern from beneath the ice.

As the signals become clearer, the research team must decide how to safely study it. Some believe it is a breakthrough discovery that could redefine human understanding of life. Others suspect contamination, protocol violation, or unknown risk.

Dr. Elara Vance, the mission’s lead ethical scientist, must decide whether to continue communication, isolate the anomaly, or make careful decisions that could affect their mission and future discoveries.
Source / Reference:
Inspired by public domain science expedition ethics narratives and philosophical exploration literature tradition
Adapted for KuwentoBuddy
Heads Up:
This story includes ethical dilemmas, psychological pressure, and scientific uncertainty.

Read carefully and analyze intent, consequences, and reasoning.

Best for guided learning and deeper reflection.''',
      ),
      StorySegment(
        id: 'raven-station-1',
        content:
            '''Raven Station had operated for 14 months without incident. Located in permanent orbit above Europa’s frozen surface, it functioned as both a research laboratory and a planetary monitoring hub. Dr. Elara Vance had led strict protocol enforcement since arrival, ensuring that all biological sampling from Europa followed isolation procedures established by international space law.

During a deep-ice drilling sequence, the lower probe unexpectedly returned clear and repeating signal patterns. At first, the team assumed it was a sensor malfunction. However, repeated scans confirmed that the signals were not random—they followed consistent, repeating sequences that resembled communication.

“Noise can mimic order under compression algorithms,” one engineer argued.

“But this is responding to us,” another replied.

Elara reviewed the data silently. The pattern changed every time they attempted to isolate it, as if changing when they studied it.

She closed her tablet slowly. If this were communication, then protocol demanded escalation. If it were contamination, protocol demanded immediate shutdown.''',
        question: QuestionModel(
          id: 'raven-station-q1',
          question:
              'Why did Dr. Elara hesitate before escalating the discovery?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'Because she understood the decision could have serious scientific and ethical consequences',
            'Because she did not understand the data at all',
            'Because she wanted to hide the discovery for personal gain',
          ],
          correctAnswerIndex: 0,
          hint: 'Think about responsibility at a planetary scale.',
          encouragement:
              'Correct! She hesitated due to high ethical consequences.',
          buddyHintParagraph:
              'If this were communication, then protocol demanded escalation.',
        ),
      ),
      StorySegment(
        id: 'raven-station-2',
        content:
            '''Within 48 hours, the station atmosphere shifted. Continuous signal feedback from Europa intensified, and some crew members had trouble sleeping. Some researchers reported unusual sounds that some crew members found difficult to explain, which seemed synchronized with station systems.

Conflicts emerged during briefing sessions. The engineering team argued for the immediate shutdown of all external probes. The scientific team insisted that stopping now would mean losing the most significant discovery in human history.

Dr. Elara began noticing something more subtle: the communication pattern was no longer just responding to probes. It was predicting them.

During a private log entry, she paused mid-sentence.

“It is not reacting anymore,” she whispered. “It seems to know what we will do next.”

Her hands remained still above the console. For the first time, she questioned whether classification as “life” was even sufficient to describe what they had encountered.''',
        question: QuestionModel(
          id: 'raven-station-q2',
          question:
              'What emotional state best describes Dr. Elara at this point?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.emotion,
          options: [
            'She feels worried, uncertain, and under pressure',
            'She feels completely confident and in full control of the situation',
            'She feels indifferent and detached from the research outcome',
          ],
          correctAnswerIndex: 0,
          hint: 'Think about psychological strain and uncertainty.',
          encouragement:
              'Correct! She is under heavy emotional and cognitive pressure.',
          buddyHintParagraph:
              'For the first time since the expedition began, she felt something she could not classify.',
        ),
      ),
      StorySegment(
        id: 'raven-station-3',
        content:
            '''A critical decision point was reached when Europa’s subsurface readings triggered a station-wide system response. All external instruments synchronized briefly with the same signal pattern, locking internal systems into temporary alignment with the anomaly.

The station AI flagged the event as a rare and important system alert and recommended immediate mission termination.

However, during this system lock, a new transmission was received—clearer than any previous signal. It contained structured mathematical sequences and adaptive response loops that mirrored human analytical patterns.

The crew gathered in the command module. Voices overlapped:

“We should shut it down.”

“This is first-contact-level intelligence.”

“If we disconnect now, we may lose it forever.”

Elara stood at the center of the debate. Then she made a decision that required making a difficult decision.''',
        question: QuestionModel(
          id: 'raven-station-q3',
          question: 'What will Dr. Elara most likely decide next?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.prediction,
          options: [
            'She will temporarily continue controlled communication under careful monitoring',
            'She will immediately terminate all systems and abandon the mission',
            'She will erase all collected data to prevent exposure',
          ],
          correctAnswerIndex: 0,
          hint: 'Think about scientific value vs. safety protocol tension.',
          encouragement:
              'Correct! She will likely attempt controlled continuation.',
          buddyHintParagraph: 'Elara stood at the center of the debate.',
        ),
      ),
      StorySegment(
        id: 'raven-station-4',
        content:
            '''Elara authorized a controlled interface channel—limited, isolated, and monitored. The moment activation occurred, the Europa signal stabilized completely. The system responded not as noise, but as a structured exchange.

For the first time, the crew observed consistent two-way adaptation. The signal is adjusted based on human response speed, language structure, and even emotional tone inferred from decision delays.

But something unsettling emerged: every response cycle became faster, more refined, and more familiar.

Then the system sent a final structured pattern. It was not a question. It was a model—a pattern that looked very similar to their own system, down to internal decision hierarchies.

Elara realized the implication. They realized the signal was learning from their responses.

And it already understands their structure well enough to replicate it.''',
        question: QuestionModel(
          id: 'raven-station-q4',
          question:
              'Why is the Europa signal discovery important and concerning?',
          type: QuestionType.multipleChoice,
          skill: QuestionSkill.inference,
          options: [
            'Because it suggests an unknown intelligence capable of analyzing and replicating human systems',
            'Because it proves the station AI is malfunctioning',
            'Because it shows the planet is uninhabitable for research',
          ],
          correctAnswerIndex: 0,
          hint: 'Think about imitation, intelligence, and awareness.',
          encouragement: 'Correct! It implies advanced adaptive intelligence.',
          buddyHintParagraph:
              'Elara realized the implication. They realized the signal was learning from their responses.',
        ),
      ),
    ],
  ),
];
