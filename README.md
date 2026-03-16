⚠️ Academic Integrity Notice: This repository is a dedicated workspace for an ongoing project at the Technological Institute of the Philippines. Access and use of these files are strictly limited to the members of Group 8 (CS32S3). We kindly ask that external visitors do not fork, pull, or distribute this source code.

# 📖 KuwentoBuddy: Your Interactive Reading Companion

**KuwentoBuddy** is a mobile learning application designed to help users of all ages improve their reading comprehension skills through an interactive and engaging experience. By transforming passive reading into an active **"Read-Think-Continue"** dialogue, the app ensures that learners don't just recognize words but truly understand the narrative flow.

---

### ✨ Key Features 🌟

* **Interactive Story Engine (Read-Think-Continue)** 📖⏯️: Stories are divided into logical segments where the app automatically pauses at critical plot points. Users must engage with comprehension questions before the story proceeds, transforming reading into an active process.
* **Supportive Buddy Companion** 🤖🤝: A friendly digital buddy stays on screen to guide the learner. It provides instant, non-punitive feedback, such as happy animations for correct answers and helpful hints when a user is stuck.
* **Leveled Content Library** 📚🌱: Stories are organized into user-friendly categories and difficulty levels, such as **Beginner**, **Intermediate**, and **Advanced**. The library includes original narratives and local **Filipino Tales** like "Alamat ng Pinya".
* **Sequence the Story Activity** 🧩🔄: After completing a story, users can practice narrative structure through a "Put It in Order" game where they arrange key events chronologically.
* **My Progress Dashboard** 📊📈: Users can track their reading journey with personalized stats, including stories completed, comprehension percentages, and daily reading streaks.
* **Spotify-Inspired UI/UX** 🎨🎶: The app features a clean, modern design with horizontal library scrolling and "Album Art" style story covers for a premium, engaging feel.

---

### 🚀 The Development Team (Group 8) 👨‍💻

The dedicated team from section **CS32S3** behind this project includes:

* **GUILLERMO, ALVIN J.** 👑
* **ROSLIN, KENDRICK A.** 🎨 
* **ROXAS, MARK KENDRICK P.** ✍️ 
* **SIMBULAN, HIRONDELLE D.** 🛠️ 



---

### 🏛️ Institutional Context 🎓

* **School:** Technological Institute of the Philippines (T.I.P.) 🏫
* **Department:** College of Computer Studies 💻 


* **Course:** ITE 010 - Introduction to Human-Computer Interaction 🖥️ 


* **Instructor:** Ms. Elizzette Joy Mationg 👩‍🏫 


* **Term:** S.Y. 2025-2026 📅 


---

*Developed with ❤️ to empower every reader.*

---

### Android Device Compatibility Checklist

To keep KuwentoBuddy working across different Android phones and build environments:

1. Keep `applicationId` as `com.kuwentobuddy.app`.
2. Use `minSdk = 21` so older Android devices can still install the app.
3. Add both debug and release SHA keys in Firebase for `com.kuwentobuddy.app`.
4. Download and replace `android/app/google-services.json` whenever SHA keys or package settings change.
5. Enable Google sign-in in Firebase Authentication.
6. Deploy Firestore rules after updates:
	`firebase deploy --only firestore:rules`

Without steps 3 to 6, Google login and cloud sync may fail on some devices/builds even if local app launch works.
