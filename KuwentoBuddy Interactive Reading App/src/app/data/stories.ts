
export interface Question {
  text: string;
  options: string[];
  correctIndex: number;
  hint: string;
}

export interface Segment {
  text: string;
  question: Question;
  image?: string;
}

export interface Story {
  id: string;
  title: string;
  category: string;
  level: string;
  coverImage: string;
  description: string;
  segments: Segment[];
  sequencingEvents: string[]; // For the post-story activity
}

export const stories: Story[] = [
  {
    id: "alamat-ng-pinya",
    title: "Alamat ng Pinya",
    category: "Filipino Tales",
    level: "Beginner",
    coverImage: "https://images.unsplash.com/photo-1728738228346-59a2b5c9a2c4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaW5lYXBwbGUlMjBpbGx1c3RyYXRpb24lMjBjYXJ0b29ufGVufDF8fHx8MTc3MTYzODE3N3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    description: "Discover why the pineapple has so many eyes in this classic Filipino legend.",
    segments: [
      {
        text: "Once upon a time, there was a young girl named Pina. She lived with her mother in a small hut. Pina was a sweet girl, but she was also very lazy. Whenever her mother asked her to find something, she would say, 'I can't find it!' without even looking.",
        image: "https://images.unsplash.com/photo-1533975197976-d29f912001f4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxnaXJsJTIwZGF5ZHJlYW1pbmclMjB3aW5kb3clMjBpbGx1c3RyYXRpb258ZW58MXx8fHwxNzcxNjQxOTM2fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        question: {
          text: "What was Pina's problem?",
          options: ["She was too busy.", "She was lazy and didn't look for things.", "She couldn't see well."],
          correctIndex: 1,
          hint: "Think about what she said to her mother when asked to find something."
        }
      },
      {
        text: "One day, her mother got very sick and couldn't cook. She asked Pina to cook some rice. 'Pina, please find the ladle so I can cook,' her mother said weakly. Pina yelled back, 'I can't find it! I looked everywhere!' Her mother, frustrated and in pain, wished, 'I wish you had a thousand eyes so you could find things easily!'",
        image: "https://images.unsplash.com/photo-1707760509939-c3204c0e2e83?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzaWNrJTIwbW90aGVyJTIwaW4lMjBiZWQlMjBiYW1ib28lMjBodXQlMjBjYXJ0b29ufGVufDF8fHx8MTc3MTY0MTkzNnww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        question: {
          text: "Why did Pina's mother make a wish?",
          options: ["She wanted a new ladle.", "She was angry that Pina wouldn't look properly.", "She wanted to give Pina a gift."],
          correctIndex: 1,
          hint: "How was the mother feeling when Pina said she couldn't find the ladle?"
        }
      },
      {
        text: "Suddenly, the hut became very quiet. Pina was nowhere to be found. Her mother searched and searched but couldn't find her. Days passed, and in the garden, a strange new fruit appeared. It had many 'eyes' all over its skin. The mother realized her wish had come true. She named the fruit 'Pinya' in memory of her daughter.",
        image: "https://images.unsplash.com/photo-1728738228346-59a2b5c9a2c4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaW5lYXBwbGUlMjBpbGx1c3RyYXRpb24lMjBjYXJ0b29ufGVufDF8fHx8MTc3MTY0MTkzNnww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        question: {
          text: "What happened to Pina?",
          options: ["She ran away.", "She turned into a fruit with many eyes.", "She hid under the bed."],
          correctIndex: 1,
          hint: "What did the mother find in the garden that reminded her of Pina?"
        }
      }
    ],
    sequencingEvents: [
      "Pina's mother asks her to find the ladle.",
      "Pina says she can't find it without looking.",
      "Mother wishes Pina had a thousand eyes.",
      "A strange fruit with many eyes appears in the garden."
    ]
  },
  {
    id: "the-magic-tree",
    title: "The Magic Tree",
    category: "Adventure Stories",
    level: "Intermediate",
    coverImage: "https://images.unsplash.com/photo-1770034285769-4a5a3f410346?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYWdpY2FsJTIwZm9yZXN0JTIwaWxsdXN0cmF0aW9ufGVufDF8fHx8MTc3MTYzODE4Nnww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    description: "Two friends discover a secret in the forest that changes everything.",
    segments: [
      {
        text: "Leo and Mia were playing in the forest behind their house. They knew every tree and every rock, or so they thought. Today, they found a path they had never seen before. It was covered in sparkling blue leaves.",
        image: "https://images.unsplash.com/photo-1692127932943-fff12442ce72?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYWdpYyUyMGZvcmVzdCUyMHBhdGglMjBibHVlJTIwbGVhdmVzJTIwY2FydG9vbnxlbnwxfHx8fDE3NzE2NDE5MzZ8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        question: {
          text: "What was unusual about the path?",
          options: ["It was muddy.", "It was covered in sparkling blue leaves.", "It was very wide."],
          correctIndex: 1,
          hint: "What color were the leaves on the path?"
        }
      },
      {
        text: "They followed the path until they reached a giant oak tree with a small door at the base. 'Should we open it?' whispered Mia. Leo nodded bravely. He reached out and turned the tiny golden handle.",
        image: "https://images.unsplash.com/photo-1684275656589-e01d51658e44?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxnaWFudCUyMG9hayUyMHRyZWUlMjBzbWFsbCUyMG1hZ2ljYWwlMjBkb29yJTIwY2FydG9vbnxlbnwxfHx8fDE3NzE2NDE5Mzd8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        question: {
          text: "How did Leo feel?",
          options: ["Scared and ran away.", "Brave enough to open the door.", "Tired and wanted to go home."],
          correctIndex: 1,
          hint: "Look at the word used to describe how Leo nodded."
        }
      }
    ],
    sequencingEvents: [
      "Leo and Mia find a new path.",
      "They see sparkling blue leaves.",
      "They find a giant tree with a door.",
      "Leo opens the tiny door."
    ]
  },
  {
    id: "monkey-and-turtle",
    title: "The Monkey and the Turtle",
    category: "Filipino Tales",
    level: "Intermediate",
    coverImage: "https://images.unsplash.com/photo-1754413810186-6ae4b94be414?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb25rZXklMjBjbGltYmluZyUyMHRyZWUlMjBjYXJ0b29ufGVufDF8fHx8MTc3MTY0MTEwNXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    description: "A clever turtle outsmarts a greedy monkey in this classic tale of wits.",
    segments: [
      {
        text: "One day, a Monkey and a Turtle found a banana tree floating in the river. They decided to share it. The Monkey, being greedy, took the top part with all the green leaves, thinking it would grow faster. The Turtle quietly took the bottom part with the roots.",
        image: "https://images.unsplash.com/photo-1656955191783-639b7494f7a9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb25rZXklMjBhbmQlMjB0dXJ0bGUlMjBjYXJ0b29uJTIwZm9yZXN0JTIwcml2ZXJ8ZW58MXx8fHwxNzcxNjQxOTQxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        question: {
          text: "Which part of the tree did the Monkey choose?",
          options: ["The roots.", "The top part with leaves.", "The middle part."],
          correctIndex: 1,
          hint: "The Monkey wanted the part that looked green and fresh."
        }
      },
      {
        text: "They planted their parts. The Monkey's top part withered and died because it had no roots. The Turtle's part grew into a strong tree with many bananas. The Monkey offered to climb the tree to get the fruit for the Turtle, but once he was up there, he ate all the bananas himself!",
        image: "https://images.unsplash.com/photo-1513098872174-2af8a3c9238a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb25rZXklMjBlYXRpbmclMjBiYW5hbmElMjBjYXJ0b29ufGVufDF8fHx8MTc3MTY0MTk0MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        question: {
          text: "What did the Monkey do with the bananas?",
          options: ["He gave them to the Turtle.", "He ate all of them.", "He saved them for later."],
          correctIndex: 1,
          hint: "The Monkey was greedy."
        }
      },
      {
        text: "The Turtle, angry but clever, placed sharp thorns around the trunk of the tree. When the Monkey came down, he got pricked and cried out in pain. He threatened to throw the Turtle into the fire or the river. 'Please don't throw me in the river, I will drown!' cried the Turtle.",
        image: "https://images.unsplash.com/photo-1763054781281-6cf189d06a2b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0dXJ0bGUlMjB3aXRoJTIwdGhvcm5zJTIwY2FydG9vbnxlbnwxfHx8fDE3NzE2NDE5NDF8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        question: {
          text: "Why did the Turtle pretend to be afraid of the river?",
          options: ["He can't swim.", "He wanted to trick the Monkey into throwing him there.", "He was cold."],
          correctIndex: 1,
          hint: "Turtles live in water."
        }
      }
    ],
    sequencingEvents: [
      "Monkey takes the top of the tree, Turtle takes the roots.",
      "Monkey eats all the bananas.",
      "Turtle puts thorns on the tree.",
      "Monkey throws Turtle into the river."
    ]
  },
  {
    id: "carabao-and-shell",
    title: "The Carabao and the Shell",
    category: "Filipino Tales",
    level: "Advanced",
    coverImage: "https://images.unsplash.com/photo-1602239019061-013553ba0d12?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3YXRlciUyMGJ1ZmZhbG8lMjBhc2lhbiUyMGFuaW1hbCUyMGNhcnRvb258ZW58MXx8fHwxNzcxNjQxMTA2fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    description: "Who is faster, the mighty Carabao or the tiny Shell? A race determines the winner.",
    segments: [
      {
        text: "One hot afternoon, a Carabao was boasting about his speed to a tiny Shell by the river. 'You are so slow,' laughed the Carabao. 'I can run faster than the wind!' The Shell simply smiled and challenged the Carabao to a race.",
        image: "https://images.unsplash.com/photo-1651959885524-e90bb78aa2c9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3YXRlciUyMGJ1ZmZhbG8lMjBjYXJhYmFvJTIwY2FydG9vbiUyMHJpdmVyfGVufDF8fHx8MTc3MTY0MTk0MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        question: {
          text: "What did the Carabao boast about?",
          options: ["His strength.", "His speed.", "His size."],
          correctIndex: 1,
          hint: "He said he can run faster than the wind."
        }
      },
      {
        text: "The race began. The Carabao ran as fast as he could. After a while, he stopped and called out, 'Shell!' To his surprise, a voice answered from ahead, 'I am here!' The Carabao ran again, faster this time. But every time he stopped and called, a Shell answered from ahead.",
        image: "https://images.unsplash.com/photo-1602239019061-013553ba0d12?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3YXRlciUyMGJ1ZmZhbG8lMjBjYXJhYmFvJTIwcnVubmluZyUyMGZhc3QlMjBjYXJ0b29ufGVufDF8fHx8MTc3MTY0MTk0Nnww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        question: {
          text: "What happened every time the Carabao called out?",
          options: ["No one answered.", "The Shell answered from behind.", "The Shell answered from ahead."],
          correctIndex: 2,
          hint: "The Carabao was surprised."
        }
      },
      {
        text: "Exhausted and defeated, the Carabao gave up. He didn't know that the Shell had asked all his friends to help. They were lined up all along the riverbank, so whenever the Carabao called, the nearest shell would answer!",
        image: "https://images.unsplash.com/photo-1763240878564-ad7c521306d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzbmFpbHMlMjByaXZlciUyMGJhbmslMjBjYXJ0b29ufGVufDF8fHx8MTc3MTY0MTk0Nnww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        question: {
          text: "How did the Shell win?",
          options: ["He ran very fast.", "He used a motorcycle.", "He got help from his friends."],
          correctIndex: 2,
          hint: "There were many shells along the river."
        }
      }
    ],
    sequencingEvents: [
      "Carabao boasts about his speed.",
      "Shell challenges Carabao to a race.",
      "Shell's friends answer from ahead along the river.",
      "Carabao gives up, exhausted."
    ]
  },
  {
    id: "maria-makiling",
    title: "Maria Makiling",
    category: "Legends",
    level: "Advanced",
    coverImage: "https://images.unsplash.com/photo-1647535196780-52c50a10ad9e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxteXN0aWNhbCUyMGZvcmVzdCUyMGZhaXJ5JTIwZ29kZGVzcyUyMGZpbGlwaW5vJTIwbWFyaWElMjBtYWtpbGluZyUyMGlsbHVzdHJhdGlvbnxlbnwxfHx8fDE3NzE2NDEwOTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    description: "The enchanting tale of the guardian spirit of Mount Makiling.",
    segments: [
      {
        text: "Maria Makiling was a beautiful diwata (fairy) who lived on Mount Makiling. She was kind and generous to the people. She would give them ginger that turned into gold. Her hair was long and black, and she wore a dress made of clouds.",
        image: "https://images.unsplash.com/photo-1584441263037-19087f63e81b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYXJpYSUyMG1ha2lsaW5nJTIwZGl3YXRhJTIwZ29kZGVzcyUyMGZvcmVzdCUyMGlsbHVzdHJhdGlvbnxlbnwxfHx8fDE3NzE2NDE5NDd8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        question: {
          text: "What gift did Maria give to people?",
          options: ["Silver coins.", "Ginger that turned into gold.", "Magic seeds."],
          correctIndex: 1,
          hint: "It started as a common kitchen spice."
        }
      },
      {
        text: "Many men fell in love with her, but she loved a simple hunter. However, the hunter was forced to marry a mortal woman. Heartbroken, Maria stopped showing herself to people. The mountain became quiet, and the gifts of gold stopped appearing.",
        image: "https://images.unsplash.com/photo-1553740316-164292569f4b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzYWQlMjB3b21hbiUyMGZhaXJ5JTIwZm9yZXN0JTIwbWlzdCUyMGlsbHVzdHJhdGlvbnxlbnwxfHx8fDE3NzE2NDE5NDZ8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        question: {
          text: "Why did Maria stop showing herself?",
          options: ["She was tired.", "She was heartbroken.", "She moved to another mountain."],
          correctIndex: 1,
          hint: "Something happened with the hunter she loved."
        }
      }
    ],
    sequencingEvents: [
      "Maria Makiling gives gold to the people.",
      "She falls in love with a hunter.",
      "The hunter marries a mortal woman.",
      "Maria disappears from the people."
    ]
  }
];
