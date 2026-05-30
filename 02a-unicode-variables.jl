# Learning goal: We can even use emoji as variable names. That is not always a good idea, but it can be handy when designing an app or GUI.

🔨 = "hammer"      # hammer label
🧭 = "compass"     # compass label
👜 = (🔨, 🧭)       # items packed in the field bag

println("Field bag contains: ", 👜[1], " and ", 👜[2])