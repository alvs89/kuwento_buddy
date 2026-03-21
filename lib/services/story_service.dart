import 'package:kuwentobuddy/models/story_model.dart';
import 'package:kuwentobuddy/models/question_model.dart';

/// Service for managing stories - simulates a local database
class StoryService {
  static final StoryService _instance = StoryService._internal();
  factory StoryService() => _instance;
  StoryService._internal();

  /// Sample stories data (JSON-style local list)
  final List<StoryModel> _stories = [
    // ===== PHILIPPINE FOLKTALES =====

    // Alamat ng Pinya (The Legend of the Pineapple)
    StoryModel(
      id: 'story_alamat_pinya',
      title: 'Alamat ng Pinya',
      author: 'Philippine Folktale',
      coverImage:
          'assets/images/magical_forest_fairy_tale_children_book_illustration_null_1773063134827.jpg',
      description:
          'A Filipino folktale about Pinang, responsibility, and the painful consequences of words spoken in anger.',
      level: StoryLevel.beginner,
      categories: [StoryCategory.filipinoTales],
      estimatedMinutes: 6,
      language: 'fil',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      segments: [
        StorySegment(
          id: 'pinya_1',
          content:
              '''Noong unang panahon may nakatirang mag-ina sa isang malayong pook. Ang ina ay si Aling Rosa at ang anak ay si Pinang. Mahal na mahal ni Aling Rosa ang kanyang bugtong na anak. Kaya lumaki si Pinang sa layaw.

Gusto ng ina na matuto si Pinang ng mga gawaing bahay, ngunit laging ikinakatwiran ni Pinang na alam na niyang gawin ang mga itinuturo ng ina. Kaya't pinabayaan na lang niya ang kanyang anak.''',
          question: QuestionModel(
            id: 'pinya_q1',
            question:
                'Bakit malamang na hindi natutong mabuti si Pinang sa mga gawaing bahay?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.inference,
            options: [
              'Dahil masyado pa siyang bata para matuto',
              'Dahil pakiramdam niya ay alam na niya, kaya hindi siya nagsanay nang maayos',
              'Dahil wala talagang gawaing bahay sa kanilang tahanan',
            ],
            correctAnswerIndex: 1,
            hint:
                'Balikan ang bahaging paulit-ulit na sinasabi ni Pinang sa kanyang ina.',
            encouragement:
                'Tama! Hindi sapat ang pagsasabing alam mo na kung hindi mo naman ito ginagawa.',
            buddyHintParagraph:
                'Laging ikinakatwiran ni Pinang na alam na niyang gawin ang itinuturo ng ina.',
          ),
        ),
        StorySegment(
          id: 'pinya_2',
          content:
              '''Isang araw nagkasakit si Aling Rosa. Hindi siya makabangon at makagawa ng gawaing bahay. Inutusan niya si Pinang na magluto ng lugaw. Isinalang ni Pinang ang lugaw ngunit napabayaan dahil sa kalalaro. Ang lugaw ay dumikit sa palayok at nasunog. Nagpasensiya na lang si Aling Rosa, napagsilbihan naman siya kahit paano ng anak.''',
          question: QuestionModel(
            id: 'pinya_q2',
            question:
                'Ano ang ipinapakita ng naging reaksyon ni Aling Rosa matapos masunog ang lugaw?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.emotion,
            options: [
              'Mas pinili niyang unawain ang anak kaysa magalit agad',
              'Wala siyang pakialam kung magkamali si Pinang',
              'Nais niyang parusahan kaagad si Pinang',
            ],
            correctAnswerIndex: 0,
            hint:
                'Pansinin na kahit may pagkukulang si Pinang, may pinili pa ring ugali si Aling Rosa.',
            encouragement:
                'Magaling! Ang pasensiya at pag-unawa ay makikita sa reaksyon ni Aling Rosa.',
            buddyHintParagraph: 'Nagpasensiya na lamang si Aling Rosa.',
          ),
        ),
        StorySegment(
          id: 'pinya_3',
          content:
              '''Nagtagal ang sakit ni Aling Rosa kaya't napilitang si Pinang ang gumagawa sa bahay. Isang araw, sa kanyang pagluluto hindi niya makita ang posporo. Tinanong ang kanyang ina kung nasaan ito. Isang beses naman ay ang sandok ang hinahanap. Ganoon ng ganoon ang nangyayari. Walang bagay na di makita at agad tinatanong ang kanyang ina. Nayamot si Aling Rosa sa katatanong ng anak kayaÂ´t nawika nito: " Naku! Pinang, sana'y magkaroon ka ng maraming mata upang makita mo ang lahat ng bagay at hindi ka na tanong nang tanong sa akin.''',
          question: QuestionModel(
            id: 'pinya_q3',
            question:
                'Bakit mahalagang bahagi ng kuwento ang nasabi ni Aling Rosa sa bahaging ito?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.inference,
            options: [
              'Dahil nagpapakita ito ng damdaming maaaring magdulot ng mabigat na resulta',
              'Dahil ibig sabihin nito ay aalis na si Aling Rosa sa bahay',
              'Dahil dito napatunayang nagbago na kaagad si Pinang',
            ],
            correctAnswerIndex: 0,
            hint:
                'Isipin kung ano ang puwedeng mangyari kapag may nasabi tayong mabigat dahil sa galit.',
            encouragement:
                'Tama! Ang mga salitang binitiwan sa galit ay puwedeng magdulot ng seryosong bunga.',
            buddyHintParagraph:
                'Nayamot si Aling Rosa sa walang tigil na pagtatanong.',
          ),
        ),
        StorySegment(
          id: 'pinya_4',
          content:
              '''Dahil alam niyang galit na ang kanyang ina ay di na umimik si Pinang. Umalis siya upang hanapin ang sandok na hinahanap. Kinagabihan, wala si Pinang sa bahay. Nabahala si Aling Rosa. Tinatawag niya ang anak ngunit walang sumasagot. Napilitan siyang bumangon at naghanda ng pagkain.

Pagkaraan ng ilang araw ay magaling-galing na si Aling Rosa. Hinanap niya si Pinang. Tinanong niya ang mga kapitbahay kung nakita nila ang kanyang anak. Ngunit naglahong parang bula si Pinang. Hindi na nakita ni Aling Rosa si Pinang.

Isang araw, may nakitang halaman si Aling Rosa sa kanyang bakuran. Hindi niya alam kung anong uri ang halamang iyon. Inalagaan niyang mabuti hanggang sa ito'y magbunga. Laking pagkamangha ni Aling Rosa ng makita ang anyo ng bunga nito. Ito'y hugis-ulo ng tao at napapalibutan ng mata.

Biglang naalaala ni Aling Rosa ang huli niyang sinabi kay Pina, na sana'y magkaroon ito ng maraming mata para makita ang kanyang hinahanap. Tahimik na nanangis si Aling Rosa at laking pagsisisi dahil tumalab ang kanyang sinabi sa anak. Inalagaan niyang mabuti ang halaman at tinawag itong Pinang, Sa palipat-lipat sa bibig ng mga tao ang pinang ay naging pinya.''',
          question: QuestionModel(
            id: 'pinya_q4',
            question:
                'Ano ang pinakamahalagang aral na ipinapakita ng wakas ng kuwento?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.inference,
            options: [
              'Ang salitang binitiwan sa galit ay maaaring magdulot ng malalim at pangmatagalang sakit',
              'Mas mabuting huwag na lang tumulong sa gawaing bahay',
              'Ang mga kapitbahay ang pangunahing responsable sa pagpapalaki ng anak',
            ],
            correctAnswerIndex: 0,
            hint:
                'Pag-isipan ang naramdaman ni Aling Rosa matapos mangyari ang lahat.',
            encouragement:
                'Napakagaling! Ang kuwento ay paalala na mag-ingat sa mga salitang sinasabi natin sa galit.',
            buddyHintParagraph: 'Tahimik siyang nanangis at nagsisi.',
          ),
        ),
      ],
    ),

    // Ang Pagong at ang Matsing (The Turtle and the Monkey)
    StoryModel(
      id: 'story_pagong_matsing',
      title: 'Ang Pagong at ang Matsing',
      author: 'Philippine Folktale',
      coverImage:
          'assets/images/tropical_jungle_adventure_children_illustration_null_1773063139698.jpg',
      description:
          'A tale about a clever turtle and a greedy monkey who find a banana tree.',
      level: StoryLevel.intermediate,
      categories: [StoryCategory.filipinoTales],
      estimatedMinutes: 8,
      language: 'fil',
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
      segments: [
        StorySegment(
          id: 'pagong_1',
          content:
              '''Isang araw, habang naglalakad si Pagong sa tabing ilog, may nakita siyang lumulutang na puno ng saging. Naisip niya, "Kung itatanim ko ito, magkakaroon ako ng sariling saging!"

Ngunit alam niyang napakahirap para sa kanya na magtanim dahil napakabagal niya at napakaliit ng kanyang mga kamay.

Dumating si Matsing at nakita rin ang puno ng saging. "Kunin natin iyan, Pagong!" sabi niya. "Hahatiin natin at pareho tayong may itatanim!"

One day, while Turtle was walking by the riverside, he saw a banana tree floating in the water. He thought, "If I plant this, I will have my own bananas!"

But he knew it would be very difficult for him to plant because he was too slow and his hands were too small.

Along came Monkey who also saw the banana tree. "Let us get that, Turtle!" he said. "We will divide it and both have something to plant!"''',
          question: QuestionModel(
            id: 'pagong_q1',
            question:
                'Why do you think Monkey wanted to share the banana tree with Turtle?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.inference,
            options: [
              'Monkey was kind and wanted to help Turtle',
              'Monkey needed Turtle\'s help to get the tree from the water',
              'Monkey did not care about the banana tree',
            ],
            correctAnswerIndex: 1,
            hint:
                'Think about what each animal is good at. Why would Monkey need Turtle for something in the river?',
            encouragement:
                'Mahusay! You figured out that Monkey needed help getting the tree from the water!',
            buddyHintParagraph: 'Nakita siyang lumulutang na puno ng saging.',
          ),
        ),
        StorySegment(
          id: 'pagong_2',
          content:
              '''Hinati nila ang puno ng saging. Pinili ni Matsing ang itaas na bahagi na may mga dahon. "Ito ang pipiliin ko dahil mas marami itong dahon!" sabi niya nang may pagmamayabang.

Si Pagong naman ay kumuha ng ibabang bahagi—ang ugat. Hindi nagsalita si Pagong at umuwi na lang.

Lumipas ang mga araw. Ang bahagi ni Matsing ay natuyo at namatay. Ngunit ang bahagi ni Pagong ay tumubo, naging matatag, at nagbunga ng masasarap na saging!

They divided the banana tree. Monkey chose the top part with the leaves. "I will choose this because it has more leaves!" he said boastfully.

Turtle took the bottom part—the roots. Turtle did not say anything and just went home.

 Days passed. Monkey's part dried up and died. But Turtle's part grew, became strong, and produced delicious bananas!''',
          question: QuestionModel(
            id: 'pagong_q2',
            question:
                'What will most likely happen when Monkey sees Turtle\'s bananas?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.prediction,
            options: [
              'Monkey will congratulate Turtle and buy bananas from him',
              'Monkey will become jealous and try to take the bananas',
              'Monkey will not care and look for another tree',
            ],
            correctAnswerIndex: 1,
            hint:
                'Remember what kind of character Monkey has shown so far. How did he act when dividing the tree?',
            encouragement:
                'Very good! You predicted correctly based on Monkey\'s greedy behavior!',
            buddyHintParagraph:
                'Pinili ni Matsing ang itaas na bahagi na may mga dahon.',
          ),
        ),
        StorySegment(
          id: 'pagong_3',
          content:
              '''Nang makita ni Matsing ang mga saging ni Pagong, inggit na inggit siya. "Pagong, pahingi naman ng saging!" sigaw niya.

"Gusto ko sana, Matsing, pero hindi ako makapag-akyat," sagot ni Pagong. "Ikaw na lang ang umakyat at mahati tayo."

Umakyat si Matsing sa puno at nagsimulang kumain ng mga saging nang hindi na bumababa. Kinain niya ang lahat ng hinog na saging at itinapon lang ang mga balat kay Pagong!

"Matsing! Hindi patas iyan!" sigaw ni Pagong. Ngunit tumawa lang si Matsing.

 When Monkey saw Turtle's bananas, he became very jealous. "Turtle, please give me some bananas!" he shouted.

 "I would like to, Monkey, but I cannot climb," Turtle answered. "Why don't you climb up and we can share?"

Monkey climbed the tree and started eating the bananas without coming down. He ate all the ripe bananas and just threw the peels at Turtle!

"Monkey! That is not fair!" shouted Turtle. But Monkey just laughed.''',
          question: QuestionModel(
            id: 'pagong_q3',
            question:
                'How is Turtle feeling right now after being tricked by Monkey?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.emotion,
            options: [
              'Turtle feels happy because Monkey is enjoying the bananas',
              'Turtle feels betrayed and angry at Monkey\'s unfairness',
              'Turtle feels sorry for Monkey',
            ],
            correctAnswerIndex: 1,
            hint:
                'Imagine working hard to grow something, then someone takes it all without sharing. How would you feel?',
            encouragement:
                'Tama ka! You understood Turtle\'s feeling of being treated unfairly.',
            buddyHintParagraph: 'Hindi patas iyan!',
          ),
        ),
        StorySegment(
          id: 'pagong_4',
          content:
              '''Naisip ni Pagong ang isang paraan. Kumuha siya ng mga tinik at matutulis na bato at inilagay sa paligid ng puno ng saging.

Nang bumaba si Matsing, natusok ang kanyang mga paa at natumba siya. Tumalon-talon siya sa sakit at sumigaw, "Aray! Aray!"

"Ngayon alam mo na kung ano ang pakiramdam ng lokohin," sabi ni Pagong. "Sana sa susunod, matuto kang maging patas at tapat."

Mula noon, laging nag-iingat si Matsing at natuto siyang huwag maging sakim.

Turtle thought of a plan. He gathered thorns and sharp stones and placed them around the banana tree.

When Monkey came down, his feet were pricked and he fell. He jumped around in pain and shouted, "Ouch! Ouch!"

"Now you know how it feels to be tricked," said Turtle. "I hope next time you learn to be fair and honest."

From then on, Monkey was always careful and learned not to be greedy.

WAKAS / THE END''',
        ),
      ],
    ),

    // Alamat ng Bundok Makiling
    StoryModel(
      id: 'story_makiling',
      title: 'Alamat ng Bundok Makiling',
      author: 'Philippine Folktale',
      coverImage:
          'assets/images/rice_terraces_Philippines_landscape_beautiful_null_1773063138652.jpg',
      description:
          'The legend of Maria Makiling, the beautiful guardian spirit of Mount Makiling.',
      level: StoryLevel.intermediate,
      categories: [StoryCategory.filipinoTales],
      estimatedMinutes: 7,
      language: 'fil',
      createdAt: DateTime(2024, 1, 3),
      updatedAt: DateTime(2024, 1, 3),
      segments: [
        StorySegment(
          id: 'makiling_1',
          content:
              '''Sa paanan ng Bundok Makiling sa Laguna, nanirahan noon ang isang marikit na diwata na nagngangalang Maria Makiling. Siya ang tagapangalaga ng bundok at lahat ng nabubuhay dito—mga hayop, halaman, at mga ilog.

Si Maria ay may mahabang buhok na kasing itim ng gabi, mga matang kulay berde ng dahon, at balat na kasing puti ng bulaklak ng sampaguita. Kahit siya ay isang diwata, minamahal niya ang mga tao at madalas siyang tumulong sa mga magsasaka.

At the foot of Mount Makiling in Laguna, there once lived a beautiful fairy named Maria Makiling. She was the guardian of the mountain and everything that lived on it—animals, plants, and rivers.

Maria had long hair as black as night, eyes as green as leaves, and skin as white as sampaguita flowers. Although she was a fairy, she loved humans and often helped the farmers.''',
          question: QuestionModel(
            id: 'makiling_q1',
            question:
                'Why do you think Maria Makiling chose to help humans even though she was a magical being?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.inference,
            options: [
              'She was bored and had nothing else to do',
              'She had a kind heart and cared about the people living near her mountain',
              'She wanted the humans to worship her',
            ],
            correctAnswerIndex: 1,
            hint:
                'Look at how Maria is described. What does the story say about her feelings toward people?',
            encouragement:
                'Mahusay! You understood Maria\'s kind and caring nature.',
            buddyHintParagraph: 'Minamahal niya ang mga tao.',
          ),
        ),
        StorySegment(
          id: 'makiling_2',
          content:
              '''Isang araw, may isang binata na nagngangalang Juan na naligaw sa kagubatan. Gutom at pagod na pagod siya. Nakita siya ni Maria at tinulungan.

"Kumain ka muna," sabi ni Maria, habang nagbibigay ng mga prutas at tubig. "At kapag nakauwi ka na, tandaan mong alagaan ang kalikasan."

Umibig si Juan kay Maria. Nangako siyang babalik siya at pakakasalan ang diwata. Ngunit nang makauwi siya sa kanyang nayon, nakita niya ang isang magandang dalaga at nakalimutan si Maria.

One day, a young man named Juan got lost in the forest. He was hungry and very tired. Maria saw him and helped.

"Eat first," said Maria, giving him fruits and water. "And when you return home, remember to take care of nature."

Juan fell in love with Maria. He promised to return and marry the fairy. But when he returned to his village, he saw a beautiful young woman and forgot about Maria.''',
          question: QuestionModel(
            id: 'makiling_q2',
            question:
                'How do you think Maria Makiling will feel when she learns that Juan broke his promise?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.emotion,
            options: [
              'She will be happy for Juan\'s new love',
              'She will feel heartbroken and betrayed',
              'She will not care because she is just a fairy',
            ],
            correctAnswerIndex: 1,
            hint:
                'Maria helped Juan and he promised to return. Imagine waiting for someone who never comes back. What would you feel?',
            encouragement:
                'Tama! Even magical beings can feel heartbreak when betrayed.',
            buddyHintParagraph: 'Nangako siyang babalik siya.',
          ),
        ),
        StorySegment(
          id: 'makiling_3',
          content:
              '''Naghintay si Maria kay Juan ngunit hindi ito bumalik. Nang malaman niya ang totoo, nasaktan nang husto ang kanyang puso.

Mula noon, hindi na nakita ni Maria ang mga tao. Naging mahiwaga ang bundok. Ang mga tao na pumapasok sa kagubatan ay naliligaw. Ang mga nananakaw ng kahoy at namamaril ng hayop ay nawawala.

Ngunit ang mga taong may mabuting puso, na gumagalang sa kalikasan, ay binibigyan pa rin ni Maria ng grasya—masaganang ani, magandang panahon, at proteksyon mula sa mga sakuna.

Maria waited for Juan, but he never returned. When she learned the truth, her heart was deeply hurt.

From then on, Maria no longer showed herself to people. The mountain became mysterious. People who entered the forest got lost. Those who cut trees illegally or hunted animals disappeared.

But those with good hearts, who respected nature, were still blessed by Maria—bountiful harvests, good weather, and protection from disasters.''',
          question: QuestionModel(
            id: 'makiling_q3',
            question:
                'What will most likely happen to someone who enters Mount Makiling to illegally cut trees?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.prediction,
            options: [
              'Maria will help them find the best trees',
              'They will get lost or face misfortune',
              'Nothing will happen because Maria is just a legend',
            ],
            correctAnswerIndex: 1,
            hint:
                'The story tells us what happens to those who disrespect nature on Maria\'s mountain.',
            encouragement:
                'Excellent! You understood the pattern of cause and effect in the story.',
            buddyHintParagraph:
                'Ang mga nananakaw ng kahoy at namamaril ng hayop ay nawawala.',
          ),
        ),
        StorySegment(
          id: 'makiling_4',
          content:
              '''Hanggang ngayon, ang Bundok Makiling ay isa pa ring mahiwagang lugar. Maraming naniniwala na si Maria ay naroon pa rin, nagbabantay sa kanyang tahanan.

Ang aral ng kwento: Dapat nating igalang at pangalagaan ang kalikasan. Dapat din tayong maging tapat sa ating mga pangako.

At kung minsan, kapag umakyat ka sa Bundok Makiling sa tahimik na hapon, maririnig mo ang mahinang awit ng hangin sa mga dahon. Iyan, sabi nila, ay ang iyak ni Maria Makiling—ang diwatang minahal ang mga tao ngunit nasaktan ng pangako na hindi tinupad.

Until today, Mount Makiling remains a mysterious place. Many believe that Maria is still there, guarding her home.

The lesson of the story: We must respect and protect nature. We must also be true to our promises.

And sometimes, when you climb Mount Makiling on a quiet afternoon, you can hear the soft song of the wind in the leaves. That, they say, is the cry of Maria Makiling—the fairy who loved humans but was hurt by a promise not kept.

WAKAS / THE END''',
        ),
      ],
    ),

    // ===== ORIGINAL STORIES =====

    // Story 1: The Magical Forest
    StoryModel(
      id: 'story_001',
      title: 'The Magical Forest',
      author: 'Maria Santos',
      coverImage:
          'assets/images/magical_forest_fairy_tale_children_book_illustration_null_1773063134827.jpg',
      description:
          'Join Luna as she discovers a hidden forest filled with talking animals and magical creatures.',
      level: StoryLevel.beginner,
      categories: [StoryCategory.fantasy, StoryCategory.nature],
      estimatedMinutes: 5,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
      segments: [
        StorySegment(
          id: 'seg_001_1',
          content:
              '''Once upon a time, in a small village near the mountains, there lived a curious girl named Luna. She had bright eyes that sparkled like stars and hair as dark as midnight.

Every day, Luna would look at the tall trees beyond her village and wonder what secrets they held. Her grandmother always told her, "The forest is magical, little one. It reveals itself only to those with pure hearts."

One sunny morning, Luna decided it was time to find out for herself.''',
          question: QuestionModel(
            id: 'q_001_1',
            question:
                'Why do you think Luna believed what her grandmother said about the forest?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.inference,
            options: [
              'Luna was scared of the forest',
              'Luna trusted her grandmother\'s wisdom and was curious',
              'Luna wanted to prove her grandmother wrong',
            ],
            correctAnswerIndex: 1,
            hint:
                'Think about Luna\'s personality. The story describes her as curious. How would a curious person react to a mysterious story?',
            encouragement:
                'Great job! You understood Luna\'s trusting and curious nature!',
            buddyHintParagraph: 'There lived a curious girl named Luna.',
          ),
        ),
        StorySegment(
          id: 'seg_001_2',
          content:
              '''Luna packed a small bag with bread and cheese, and walked toward the edge of the forest. As she stepped between the first two trees, something amazing happened!

The leaves above her began to glow with a soft golden light. Tiny fireflies appeared, dancing around her like welcoming friends. Luna gasped with wonder.

"Welcome, young one," said a gentle voice. Luna looked down to see a small rabbit wearing a tiny vest made of leaves.''',
          question: QuestionModel(
            id: 'q_001_2',
            question:
                'What do you think will happen next in Luna\'s adventure?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.prediction,
            options: [
              'Luna will run away scared',
              'The rabbit will guide Luna deeper into the magical forest',
              'Luna will wake up from a dream',
            ],
            correctAnswerIndex: 1,
            hint:
                'The rabbit greeted Luna kindly and the forest seems welcoming. What would a friendly guide do?',
            encouragement: 'Wonderful! The forest truly is magical!',
            buddyHintParagraph: 'Welcome, young one.',
          ),
        ),
        StorySegment(
          id: 'seg_001_3',
          content:
              '''"I am Pip," said the rabbit with a bow. "I have been waiting for someone like you. The forest needs your help!"

Luna knelt down to speak with Pip. "How can I help?" she asked.

"Our Crystal Stream has stopped flowing," Pip explained sadly. "Without it, the flowers cannot bloom and the animals cannot drink. Will you help us find out why?"

Luna nodded bravely. "I will do my best!"

Together, Luna and Pip set off deeper into the magical forest, ready for their adventure.''',
          question: QuestionModel(
            id: 'q_001_3',
            question: 'How is Luna feeling about helping the forest animals?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.emotion,
            options: [
              'She feels scared and wants to go home',
              'She feels brave and determined to help',
              'She feels angry that they asked her',
            ],
            correctAnswerIndex: 1,
            hint:
                'Look at how Luna responded to Pip\'s request. What do her words and actions tell us?',
            encouragement: 'Perfect! You understood Luna\'s brave spirit!',
            buddyHintParagraph: 'Luna nodded bravely.',
          ),
        ),
        StorySegment(
          id: 'seg_001_4',
          content:
              '''After walking through fields of glowing mushrooms and past singing birds, Luna and Pip found the source of the Crystal Stream. A large rock had fallen and blocked the water!

"I can move this," said Luna, pushing with all her might. But it was too heavy for one person.

Just then, all the forest animals gathered around. Squirrels, deer, birds, and even a friendly bear came to help. Together, they pushed the rock aside.

The water burst free, sparkling like diamonds in the sunlight. The forest came alive with color as flowers bloomed instantly.

"Thank you, Luna!" cheered all the animals. "You have a pure heart indeed!"

And from that day on, Luna visited her magical forest friends every week, always ready for a new adventure.

THE END''',
        ),
      ],
    ),

    // Story 2: The Dragon's Secret
    StoryModel(
      id: 'story_002',
      title: 'The Dragon\'s Secret',
      author: 'Carlos Reyes',
      coverImage:
          'assets/images/dragon_castle_fantasy_children_illustration_null_1773063135821.jpg',
      description:
          'A brave young knight discovers that the castle dragon isn\'t scary at all - he\'s just lonely.',
      level: StoryLevel.intermediate,
      categories: [StoryCategory.fantasy, StoryCategory.adventure],
      estimatedMinutes: 7,
      createdAt: DateTime(2024, 2, 10),
      updatedAt: DateTime(2024, 2, 10),
      segments: [
        StorySegment(
          id: 'seg_002_1',
          content:
              '''In the Kingdom of Silverstone, everyone feared the dragon that lived in the old tower. "Stay away from the tower!" parents would warn their children. "The dragon will eat you!"

But young knight-in-training, Marco, wasn't so sure. At night, he would hear strange sounds coming from the tower. They didn't sound like roars. They sounded more like... crying?

One evening, Marco gathered his courage and climbed the tower stairs.''',
          question: QuestionModel(
            id: 'q_002_1',
            question:
                'Why do you think Marco decided to investigate the tower despite the warnings?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.inference,
            options: [
              'He wanted to be famous for defeating a dragon',
              'He noticed something different about the sounds and was curious',
              'His friends dared him to go',
            ],
            correctAnswerIndex: 1,
            hint:
                'The story mentions that Marco heard sounds that didn\'t seem like roaring. What would make someone question a scary story?',
            encouragement: 'Excellent observation skills!',
            buddyHintParagraph:
                'They didn\'t sound like roars. They sounded more like... crying?',
          ),
        ),
        StorySegment(
          id: 'seg_002_2',
          content:
              '''At the top of the tower, Marco found the dragon. But it wasn't what he expected at all. The dragon was small, no bigger than a horse, with shimmering purple scales and big, sad eyes.

"Please don't run away," the dragon said softly. "Everyone always runs away."

Marco took a deep breath. "I'm not running. I'm Marco. What's your name?"

The dragon blinked in surprise. "I'm Violet. No one has ever asked me that before."

Marco sat down beside Violet and asked, "Why do you stay up here all alone?"''',
          question: QuestionModel(
            id: 'q_002_2',
            question: 'How did Violet feel when Marco asked her name?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.emotion,
            options: [
              'Angry because Marco bothered her',
              'Surprised and touched because no one had shown her kindness before',
              'Scared that Marco would attack her',
            ],
            correctAnswerIndex: 1,
            hint:
                'Think about how lonely Violet has been. How would you feel if someone showed you kindness after being alone for so long?',
            encouragement: 'You really understand how Violet felt!',
            buddyHintParagraph: 'No one has ever asked me that before.',
          ),
        ),
        StorySegment(
          id: 'seg_002_3',
          content:
              '''Violet's eyes filled with tears. "Long ago, people were scared of me because I look different. They said mean things and threw stones. So I hid up here where I couldn't hurt anyone or be hurt."

Marco felt his heart ache for the lonely dragon. "That's not fair," he said. "You seem really kind."

"I am kind!" Violet exclaimed. "I can do all sorts of helpful things. Watch!" She breathed out a gentle flame that lit up the dark room with warm, cozy light.

Marco had an idea. "What if I told everyone the truth about you? Would you come down from the tower?"

Violet thought for a moment, hope slowly filling her eyes. "You would do that for me?"

"That's what friends do," Marco smiled.''',
          question: QuestionModel(
            id: 'q_002_3',
            question:
                'What do you think will happen when Marco tells the village about Violet?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.prediction,
            options: [
              'Everyone will immediately accept Violet',
              'Some people will be hesitant at first, but they\'ll see she\'s kind',
              'The village will attack the tower',
            ],
            correctAnswerIndex: 1,
            hint:
                'Marco is one person changing his mind. Big changes in how people think usually happen gradually.',
            encouragement: 'Amazing! You understand true friendship!',
            buddyHintParagraph: 'That\'s what friends do.',
          ),
        ),
        StorySegment(
          id: 'seg_002_4',
          content:
              '''The next day, Marco called a meeting in the village square. He was nervous, but he spoke from his heart.

"Violet the dragon is not scary," he announced. "She's kind and helpful, and she's been lonely for too long. Give her a chance!"

Slowly, Violet emerged from behind a building, her purple scales glittering nervously. A little girl walked up to her first.

"You're pretty," the girl said, touching Violet's scales gently.

Violet smiled, and a happy tear rolled down her cheek.

From that day on, Violet became the village's best friend. She lit lanterns at night, kept everyone warm in winter, and most importantly, she was never lonely again.

THE END''',
        ),
      ],
    ),

    // Story 3: The Wise Owl of Mount Apo
    StoryModel(
      id: 'story_003',
      title: 'The Wise Owl of Mount Apo',
      author: 'Ana Dela Cruz',
      coverImage:
          'assets/images/friendly_owl_forest_children_book_null_1773063137821.jpg',
      description:
          'A Filipino folktale about wisdom, patience, and the importance of listening.',
      level: StoryLevel.beginner,
      categories: [StoryCategory.filipinoTales, StoryCategory.nature],
      estimatedMinutes: 4,
      createdAt: DateTime(2024, 3, 5),
      updatedAt: DateTime(2024, 3, 5),
      segments: [
        StorySegment(
          id: 'seg_003_1',
          content:
              '''High atop Mount Apo, the tallest mountain in the Philippines, lived a very old and very wise owl named Tandang Uwak.

Animals from all over would climb the mountain to ask him questions. "How do I become stronger?" asked the monkey. "How do I run faster?" asked the deer.

But Tandang Uwak's answer was always the same: "First, you must learn to listen."

One day, a young eagle named Agila flew up to the owl. "I want to be the best flyer in all the islands!" she declared proudly.''',
          question: QuestionModel(
            id: 'q_003_1',
            question:
                'Why do you think Tandang Uwak always gave the same advice about listening?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.inference,
            options: [
              'He couldn\'t think of other answers',
              'He believed listening is the foundation of all learning',
              'He wanted the animals to leave him alone',
            ],
            correctAnswerIndex: 1,
            hint:
                'Think about what makes the owl so wise. What does he know that the young animals don\'t?',
            encouragement: 'Perfect! Listening is the first step to wisdom!',
            buddyHintParagraph: 'First, you must learn to listen.',
          ),
        ),
        StorySegment(
          id: 'seg_003_2',
          content:
              '''"To fly your best," said Tandang Uwak, "you must listen to the wind."

"Listen to the wind? That's silly!" Agila laughed. "I already know how to fly!" And she flew away without waiting for more advice.

The next day, a big storm came. Agila tried to fly through it using all her strength, but the wind pushed her around. She got tired and fell.

Tandang Uwak found her and brought her back to safety.

"I should have listened," Agila admitted sadly.''',
          question: QuestionModel(
            id: 'q_003_2',
            question: 'How is Agila feeling after being rescued?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.emotion,
            options: [
              'Proud that she tried to fly through the storm',
              'Humble and regretful that she didn\'t listen to the owl',
              'Angry at the wind for being too strong',
            ],
            correctAnswerIndex: 1,
            hint:
                'Agila said she should have listened. What does that tell us about how she feels?',
            encouragement: 'Exactly right! Listening is important!',
            buddyHintParagraph: 'I should have listened.',
          ),
        ),
        StorySegment(
          id: 'seg_003_3',
          content: '''"It's not too late to learn," smiled the wise owl.

This time, Agila listened carefully. Tandang Uwak taught her to feel the wind's direction, to ride the air currents, and to rest when needed.

Days later, another storm came. But this time, Agila listened to the wind. She flew with it instead of against it, soaring higher than ever before.

"Thank you, Tandang Uwak!" she called out joyfully.

The old owl nodded wisely. "Remember, the greatest strength comes from knowing when to listen."

And Agila became the wisest flyer in all the Philippine islands—not because she was the strongest, but because she learned to listen.

THE END''',
        ),
      ],
    ),

    // Story 4: The Rice Terraces Mystery
    StoryModel(
      id: 'story_004',
      title: 'The Rice Terraces Mystery',
      author: 'Jose Villanueva',
      coverImage:
          'assets/images/rice_terraces_Philippines_landscape_beautiful_null_1773063138652.jpg',
      description:
          'Discover the ancient wonders of the Banaue Rice Terraces through a young explorer\'s eyes.',
      level: StoryLevel.intermediate,
      categories: [StoryCategory.filipinoTales, StoryCategory.adventure],
      estimatedMinutes: 6,
      createdAt: DateTime(2024, 3, 20),
      updatedAt: DateTime(2024, 3, 20),
      segments: [
        StorySegment(
          id: 'seg_004_1',
          content:
              '''Maya had always heard stories about the Banaue Rice Terraces from her Lola. "They are the Stairway to the Sky," Lola would say, "carved by our ancestors 2,000 years ago with their bare hands."

When Maya finally visited with her family, she couldn't believe her eyes. The terraces stretched up the mountains like giant green steps, glittering with water under the morning sun.

"How is this possible?" Maya whispered. "How did they build something so beautiful without machines?"''',
          question: QuestionModel(
            id: 'q_004_1',
            question:
                'Why do you think Maya was so amazed by the Rice Terraces?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.inference,
            options: [
              'She had never seen mountains before',
              'She understood how difficult it must have been to build without modern tools',
              'She thought they were ugly',
            ],
            correctAnswerIndex: 1,
            hint:
                'Maya asked how they built it "without machines." What does this question tell us about her thoughts?',
            encouragement: 'Beautiful! You remembered the special name!',
            buddyHintParagraph:
                'How did they build something so beautiful without machines?',
          ),
        ),
        StorySegment(
          id: 'seg_004_2',
          content:
              '''As Maya explored, she met an old farmer named Tatang Ben. He was tending to the rice plants with care.

"These terraces are alive," Tatang Ben explained. "The water flows from the mountains through bamboo pipes our ancestors created. Every terrace feeds the one below it."

Maya watched the water trickle down from step to step. It was like a living system!

"Our ancestors didn't have machines," Tatang Ben continued, "but they had something more powerful—teamwork and patience. Thousands of people worked together, generation after generation."''',
          question: QuestionModel(
            id: 'q_004_2',
            question:
                'What do you think Maya learned about what makes truly great achievements?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.inference,
            options: [
              'You need expensive machines to build great things',
              'Working together over time is more powerful than technology',
              'Old things are not as good as new things',
            ],
            correctAnswerIndex: 1,
            hint:
                'Remember what Tatang Ben said was more powerful than machines.',
            encouragement: 'Wonderful! Teamwork makes dreams work!',
            buddyHintParagraph:
                'They had something more powerful—teamwork and patience.',
          ),
        ),
        StorySegment(
          id: 'seg_004_3',
          content:
              '''Maya helped Tatang Ben plant some rice seedlings. Her hands got muddy, but she didn't mind.

"When you plant rice here," Tatang Ben said, "you become part of a 2,000-year-old tradition. You connect with all the people who came before you."

Maya felt something special growing in her heart—pride for her ancestors and respect for the land.

Before leaving, she looked back at the terraces one more time. They weren't just stairs made of earth and stone. They were a gift from the past, a reminder that when people work together with love and patience, they can create wonders that last forever.

"I'll come back," Maya promised. "And I'll bring my children someday."

THE END''',
        ),
      ],
    ),

    // Story 5: Ocean Secrets
    StoryModel(
      id: 'story_005',
      title: 'Ocean Secrets',
      author: 'Elena Marino',
      coverImage:
          'assets/images/underwater_ocean_mermaid_children_story_null_1773063136715.png',
      description:
          'Dive deep into the ocean to discover the amazing creatures that live beneath the waves.',
      level: StoryLevel.advanced,
      categories: [StoryCategory.nature, StoryCategory.adventure],
      estimatedMinutes: 8,
      createdAt: DateTime(2024, 4, 1),
      updatedAt: DateTime(2024, 4, 1),
      segments: [
        StorySegment(
          id: 'seg_005_1',
          content:
              '''Deep beneath the sparkling blue waters of the Philippine Sea, a young seahorse named Kabayo dreamed of exploring the Great Coral Kingdom.

"Stay close to home," his mother always warned. "The ocean is vast and full of dangers."

But Kabayo was curious. Every day, he watched colorful fish swim past, heading toward the distant coral reefs. What wonders awaited there?

One morning, when a gentle current swept through his home, Kabayo made a decision. He would follow it—just a little way—to see what lay beyond.''',
          question: QuestionModel(
            id: 'q_005_1',
            question:
                'Why do you think Kabayo decided to leave despite his mother\'s warnings?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.inference,
            options: [
              'He wanted to worry his mother',
              'His curiosity was stronger than his fear',
              'He was forced to leave',
            ],
            correctAnswerIndex: 1,
            hint:
                'Think about what drives Kabayo. The story describes him watching other fish and wondering.',
            encouragement: 'Great! Adventures await the curious!',
            buddyHintParagraph: 'Kabayo was curious.',
          ),
        ),
        StorySegment(
          id: 'seg_005_2',
          content:
              '''The current carried Kabayo past gardens of swaying seaweed and schools of shimmering silver fish. Then he saw it—the Great Coral Kingdom!

It was more beautiful than he had ever imagined. Corals of every color—pink, orange, purple, blue—rose like underwater castles. Fish of all shapes danced between them.

But something was wrong. Many corals were turning white, and some fish looked sad.

A wise old turtle swam up to Kabayo. "The water is getting warmer," she explained. "When it's too warm, the corals get sick and lose their color."

Kabayo felt worried. "Is there anything we can do?"''',
          question: QuestionModel(
            id: 'q_005_2',
            question:
                'How is Kabayo feeling after learning about the coral\'s problem?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.emotion,
            options: [
              'Excited because the corals are changing color',
              'Worried and wanting to help',
              'Bored and wanting to go home',
            ],
            correctAnswerIndex: 1,
            hint:
                'Look at Kabayo\'s question to the turtle. What does asking "Is there anything we can do?" tell us?',
            encouragement: 'Correct! Climate affects ocean life!',
            buddyHintParagraph: 'Is there anything we can do?',
          ),
        ),
        StorySegment(
          id: 'seg_005_3',
          content:
              '''The wise turtle smiled. "Every creature can help. The parrotfish eat algae that would otherwise smother the coral. The clownfish protect the anemones. Even tiny creatures like you have a role."

"What can a small seahorse do?" Kabayo asked.

"You can carry seeds," the turtle said. "The underwater plants you help spread create homes for baby fish. And those fish keep the ecosystem balanced."

Kabayo realized something important: no matter how small you are, you matter. Every creature in the ocean is connected, like threads in a beautiful tapestry.''',
          question: QuestionModel(
            id: 'q_005_3',
            question:
                'What important lesson did Kabayo learn about making a difference?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.inference,
            options: [
              'Only big animals can make important changes',
              'Everyone, no matter how small, has a valuable role to play',
              'The ocean doesn\'t need anyone\'s help',
            ],
            correctAnswerIndex: 1,
            hint:
                'Think about what the turtle taught about connections between all creatures.',
            encouragement: 'Wonderful! We are all connected!',
            buddyHintParagraph: 'No matter how small you are, you matter.',
          ),
        ),
        StorySegment(
          id: 'seg_005_4',
          content:
              '''From that day on, Kabayo became a messenger of the sea. He traveled between coral gardens, carrying seeds and spreading the word about taking care of the ocean.

"Even creatures on land can help," the turtle had told him. "When they keep the beaches clean and protect the water, they help all of us."

Kabayo returned home a changed seahorse. He was still small, but he knew now that small actions, done by many, can create big changes.

When he had baby seahorses of his own, he didn't just warn them about dangers. He taught them about the wonders of the ocean and how every creature—big or small—has the power to make a difference.

THE END''',
        ),
      ],
    ),

    // Story 6: The Jungle Adventure
    StoryModel(
      id: 'story_006',
      title: 'The Jungle Adventure',
      author: 'Rico Fernandez',
      coverImage:
          'assets/images/tropical_jungle_adventure_children_illustration_null_1773063139698.jpg',
      description:
          'A quick adventure through the tropical jungle with exciting animal friends.',
      level: StoryLevel.beginner,
      categories: [StoryCategory.quickReads, StoryCategory.adventure],
      estimatedMinutes: 3,
      createdAt: DateTime(2024, 4, 15),
      updatedAt: DateTime(2024, 4, 15),
      segments: [
        StorySegment(
          id: 'seg_006_1',
          content:
              '''Tiko the monkey swung through the jungle trees, looking for his friends. The jungle was full of sounds—birds singing, frogs croaking, and leaves rustling.

"Hello!" called Tiko. "Anyone want to play?"

A colorful parrot flew down. "I do! Let's have a race!"

They zoomed through the trees—Tiko swinging, the parrot flying. It was so much fun!''',
          question: QuestionModel(
            id: 'q_006_1',
            question:
                'Why do you think Tiko and the parrot enjoy racing together?',
            type: QuestionType.multipleChoice,
            skill: QuestionSkill.inference,
            options: [
              'They want to prove who is better',
              'They enjoy having fun and playing with friends',
              'They are trying to escape from danger',
            ],
            correctAnswerIndex: 1,
            hint:
                'What does the story say about how they feel during the race?',
            encouragement: 'That\'s right! Friends have fun together!',
            buddyHintParagraph: 'It was so much fun!',
          ),
        ),
        StorySegment(
          id: 'seg_006_2',
          content:
              '''At the finish line, they found more friends—a friendly frog and a playful butterfly.

"Let's all play together!" said the frog.

They played hide-and-seek until the sun began to set. The sky turned orange and pink.

"Same time tomorrow?" asked the butterfly.

"Definitely!" they all cheered.

The jungle was the best place to have friends and adventures.

THE END''',
        ),
      ],
    ),
  ];

  /// Get all stories
  List<StoryModel> getAllStories() => List.unmodifiable(_stories);

  /// Get story by ID
  StoryModel? getStoryById(String id) {
    try {
      return _stories.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get stories by category
  List<StoryModel> getStoriesByCategory(StoryCategory category) =>
      _stories.where((s) => s.categories.contains(category)).toList();

  /// Get stories by level
  List<StoryModel> getStoriesByLevel(StoryLevel level) =>
      _stories.where((s) => s.level == level).toList();

  /// Get recommended stories (for now, returns varied selection)
  List<StoryModel> getRecommendedStories() => _stories.take(5).toList();

  /// Get Filipino tales
  List<StoryModel> getFilipinoTales() =>
      getStoriesByCategory(StoryCategory.filipinoTales);

  /// Get quick reads
  List<StoryModel> getQuickReads() =>
      getStoriesByCategory(StoryCategory.quickReads);

  /// Search stories by title or description
  List<StoryModel> searchStories(String query) {
    final lowerQuery = query.toLowerCase();
    return _stories
        .where((s) =>
            s.title.toLowerCase().contains(lowerQuery) ||
            s.description.toLowerCase().contains(lowerQuery) ||
            s.author.toLowerCase().contains(lowerQuery))
        .toList();
  }
}

