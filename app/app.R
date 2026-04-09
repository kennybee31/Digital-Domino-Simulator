# ==============================================================================
# Project: Digital Domino - Life Regeneration Simulator (ShinyLive Font Fix)
# 指示：修正中文字標方塊問題，其餘功能與 ISO 42001 宣告保持不變
# ==============================================================================

# 1. 套件依賴 (新增 showtext 處理中文字型)
if (!require("pacman")) install.packages("pacman")
pacman::p_load(shiny, bslib, tidyverse, scales, shinyjs, shinyWidgets, munsell, showtext)

# --- 重要：中文字型載入設定 (專為 ShinyLive 設計) ---
# 下載 Google 的 Noto Sans TC (思源黑體) 確保瀏覽器能正確渲染中文
font_add_google("Noto Sans TC", "noto_sans_tc")
showtext_auto() # 自動套用至所有繪圖裝置

# ------------------------------------------------------------------------------
# 2. 嚴謹雙語字典 (i18n) - 保持 V10 內容
# ------------------------------------------------------------------------------
i18n <- list(
  "中文" = list(
    app_title = "🌟 數位骨牌：生命再生模擬器 🌟",
    sb_title = "🎮 玩家行為設定",
    lb_hours = "每日螢幕使用 (小時)：",
    lb_pickups = "每日手機拿起次數 (次)：",
    lb_act = "選擇今日替代活動：",
    choices_act = c("戶外運動", "深度閱讀", "自然旅遊", "正念冥想", "專注寫作", "藝術繪畫"),
    lb_act_hrs = "預計投入時數 (小時)：",
    btn_reward = "🎁 抽取生命再生獎勵 (安全笑話)！",
    disc_title = "⚠️ 數據溯源與合規宣告",
    disc_1 = "📊 數據：Kaggle 全球行為數據集與 RescueTime 統計。",
    disc_2 = "🧮 模型：PRA 概率風險評估，推演 30 天累積效應。",
    disc_3 = "🛡️ 規範：符合 ISO 42001 倫理規範。數據僅供參考，非醫療診斷。",
    disc_4 = "📝 內容：內建幽默小語由團隊基於公有領域精選改寫，確保無偏見且符合心理安全。",
    disc_5 = "🖼️ 圖片：採用 LoremFlickr 隨機 API (標籤限制：funny, cute, animal)。",
    plot_title = "📉 10 大骨牌連鎖效應 (漸層能量波浪)",
    risk_title = "🏎️ 系統過載：大腦引擎指數",
    reward_title = "🎉 專屬生命再生笑話與圖卡",
    dominoes = c("視力乾澀", "頸椎僵硬", "睡眠碎裂", "腦霧現象", "專注崩盤", 
                 "情緒暴躁", "社交退縮", "體態走鐘", "決策疲勞", "深度思考喪失"),
    status_stand = "健康 (安全)",
    status_fall = "崩潰 (倒下)",
    engine_safe = "✨🟢 引擎運轉順暢：轉速正常，持續前進！",
    engine_warn = "⚠️🌡️ 溫度上升：大腦引擎過熱，請散熱！",
    engine_erupt = "💥🔥 引擎爆缸：系統熔毀！請立刻休息！",
    reward_msg_prefix = "恭喜解鎖身心再生靈感："
  ),
  "English" = list(
    app_title = "🌟 Digital Domino: Regeneration Simulator 🌟",
    sb_title = "🎮 Player Settings",
    lb_hours = "Daily Screen Time (Hours):",
    lb_pickups = "Daily Phone Pickups:",
    lb_act = "Choose Alternative Activity:",
    choices_act = c("Outdoor Sports", "Deep Reading", "Nature Travel", "Mindfulness", "Focused Writing", "Art & Painting"),
    lb_act_hrs = "Expected Duration (Hours):",
    btn_reward = "🎁 Draw Regeneration Reward (Joke)!",
    disc_title = "⚠️ Data Provenance & Compliance",
    disc_1 = "📊 Source: Kaggle & RescueTime global stats.",
    disc_2 = "🧮 Model: PRA Probabilistic Risk Assessment over 30 days.",
    disc_3 = "🛡️ Compliance: ISO 42001 compliant. For education, not a medical tool.",
    disc_4 = "📝 Content: Built-in jokes are curated and rewritten from public domain sources.",
    disc_5 = "🖼️ Image: Powered by LoremFlickr Random API (funny, cute, animal).",
    plot_title = "📉 10 Domino Effects (Gradient Energy Wave)",
    risk_title = "🏎️ System Overload: Brain Engine RPM Index",
    reward_title = "🎉 Exclusive Regeneration Joke & Card",
    dominoes = c("Dry Eyes", "Text Neck", "Broken Sleep", "Brain Fog", "Focus Collapse", 
                 "Irritability", "Social Anxiety", "Weight Gain", "Decision Fatigue", "Loss of Deep Thought"),
    status_stand = "Healthy (Safe)",
    status_fall = "Fallen (Collapsed)",
    engine_safe = "✨🟢 Smooth: RPM normal, keep cruising!",
    engine_warn = "⚠️🌡️ Overheating: Brain engine is hot, cool down!",
    engine_erupt = "💥🔥 Engine Blown: Meltdown! Pull over and rest!",
    reward_msg_prefix = "Achievement Unlocked: Mindful Inspiration:"
  )
)

# ------------------------------------------------------------------------------
# 3. 活潑主題與 CSS (Minty 風格) - 保持 V10 樣式
# ------------------------------------------------------------------------------
lively_theme <- bs_theme(
  version = 5,
  bootswatch = "minty",
  primary = "#FF6B6B",
  secondary = "#4ECDC4",
  base_font = font_google("Nunito")
)

custom_css <- "
  .card { border-radius: 20px; box-shadow: 0 8px 15px rgba(0,0,0,0.05); border: none; margin-bottom: 20px; }
  .card-header { background: linear-gradient(135deg, #4ECDC4, #556270); color: white; border-radius: 20px 20px 0 0 !important; font-weight: bold; font-size: 1.1rem; }
  .btn-reward { background: linear-gradient(135deg, #FF6B6B, #FF8E53); border: none; color: white; font-size: 1.2rem; border-radius: 30px; transition: transform 0.2s; }
  .btn-reward:hover { transform: scale(1.05); color: white; }
  .disclaimer-box { background-color: #ffffff; padding: 15px; border-radius: 15px; border-left: 5px solid #4ECDC4; font-size: 0.8rem; color: #7f8c8d; }
"

ui <- fluidPage(
  theme = lively_theme,
  useShinyjs(),
  tags$head(tags$style(HTML(custom_css))),
  
  div(style = "display: flex; justify-content: space-between; align-items: center; padding: 20px 0;",
      h2(textOutput("app_title"), style = "margin: 0; font-weight: 800; color: #4ECDC4;"),
      radioGroupButtons("lang", choices = c("中文", "English"), status = "primary", size = "sm")
  ),
  
  uiOutput("main_ui")
)

# ------------------------------------------------------------------------------
# 4. 伺服器邏輯
# ------------------------------------------------------------------------------
server <- function(input, output, session) {
  t <- reactive({ i18n[[input$lang]] })
  output$app_title <- renderText({ t()$app_title })
  
  output$main_ui <- renderUI({
    page_sidebar(
      sidebar = sidebar(
        width = 350,
        title = span(t()$sb_title, style="font-size:1.2rem; font-weight:bold;"),
        sliderInput("hours", t()$lb_hours, min = 0, max = 24, value = 6, step = 0.5),
        sliderInput("pickups", t()$lb_pickups, min = 10, max = 250, value = 50, step = 5),
        hr(style = "border-top: 2px dashed #FF6B6B;"),
        pickerInput("activity", t()$lb_act, choices = t()$choices_act),
        sliderInput("act_hours", t()$lb_act_hrs, min = 0.5, max = 12, value = 1, step = 0.5),
        actionButton("draw_reward", t()$btn_reward, class = "btn-reward w-100 btn-lg"),
        hr(),
        div(class = "disclaimer-box",
            h6(t()$disc_title, style="font-weight:bold; color:#4ECDC4; margin-bottom: 12px;"),
            p(t()$disc_1), p(t()$disc_2), p(t()$disc_3), p(t()$disc_4), p(t()$disc_5))
      ),
      layout_columns(
        fill = TRUE,
        card(card_header(t()$plot_title), plotOutput("wave_plot", height = "500px")),
        card(card_header(t()$risk_title), uiOutput("engine_display", height = "500px")),
        card(full_screen = TRUE, card_header(t()$reward_title), uiOutput("reward_display", height = "500px"))
      )
    )
  })
  
  metrics <- reactive({
    monthly_hours <- (input$hours %||% 6) * 30
    monthly_pickups <- (input$pickups %||% 50) * 30
    overload_pct <- min(100, (monthly_hours / 360) * 60 + (monthly_pickups / 6000) * 40)
    list(overload = overload_pct)
  })
  
  # 修改 1：修正中文字型顯示的波浪圖
  output$wave_plot <- renderPlot({
    res <- metrics()
    lvl <- res$overload
    x_seq <- seq(1, 10, length.out = 300)
    base_y <- 100 - (lvl * ((x_seq - 1) / 9)) 
    wave_y <- base_y + sin(x_seq * (1 + lvl/20)) * (lvl/4)
    wave_y <- pmax(0, pmin(100, wave_y)) 
    
    df_wave <- data.frame(Stage = x_seq, Health = wave_y)
    df_labels <- data.frame(x = 1:10, y = -12, label = t()$dominoes)
    
    ggplot() +
      geom_segment(data = df_wave, aes(x = Stage, xend = Stage, y = 0, yend = Health, color = Stage), size = 2.5) +
      scale_color_gradientn(colors = c("#4ECDC4", "#FDCB6E", "#FF6B6B")) +
      geom_line(data = df_wave, aes(x = Stage, y = Health), color = "white", size = 1.5, alpha = 0.5) +
      geom_text(data = df_labels, aes(x = x, y = y, label = label),
                angle = 45, hjust = 1, size = 5.5, fontface = "bold", 
                color = "#2C3E50", 
                # 關鍵：指定使用下載好的中文字型
                family = "noto_sans_tc") +
      coord_cartesian(ylim = c(-30, 110), clip = "off") + 
      theme_void() +
      theme(plot.margin = margin(20, 10, 80, 10), legend.position = "none")
  })
  
  # 修改 2：數位引擎儀表 (也需指定字型，防止 % 符號或標題亂碼)
  output$engine_display <- renderUI({
    res <- metrics(); lvl <- res$overload
    if(lvl > 70) { status_color <- "#FF6B6B"; status_text <- t()$engine_erupt; emoji <- "💥🔥🚗" 
    } else if(lvl > 30) { status_color <- "#FDCB6E"; status_text <- t()$engine_warn; emoji <- "⚠️🌡️🚗"
    } else { status_color <- "#4ECDC4"; status_text <- t()$engine_safe; emoji <- "✨🟢🚗" }
    
    div(style = "text-align: center; padding: 20px; height: 100%; display: flex; flex-direction: column; justify-content: space-around;",
        plotOutput("engine_rpm_plot", height = "280px"),
        div(hr(style = "border-top: 2px dashed #BDC3C7; width: 90%; margin: 10px auto;"),
            div(style = "font-size: 90px; line-height: 1.2; margin-bottom: 5px;", emoji),
            p(status_text, style = paste0("font-size: 24px; font-weight: bold; color: ", status_color, ";")))
    )
  })
  
  output$engine_rpm_plot <- renderPlot({
    res <- metrics(); lvl <- res$overload
    blocks <- data.frame(x = seq(2, 98, by = 4), y = 1)
    blocks$color <- ifelse(blocks$x <= lvl,
                           ifelse(blocks$x > 70, "#FF6B6B", ifelse(blocks$x > 30, "#FDCB6E", "#4ECDC4")),
                           "#E0E0E0") 
    ggplot(blocks, aes(x = x, y = y)) +
      geom_col(aes(fill = color), width = 3, show.legend = FALSE) +
      scale_fill_identity() +
      annotate("text", x = 50, y = 0.5, label = paste0(round(lvl, 1), "%"), 
               color = "#2C3E50", fontface = "bold", size = 22, family = "noto_sans_tc") +
      coord_cartesian(ylim = c(0, 1.2)) + theme_void()
  })
  
  # 笑話池與獎勵邏輯 - 保持 V10 不變
  joke_pool <- list(
    "中文" = list(
      "戶外運動" = c("🏃‍♂️ 我去健身房問教練：『我想讓全身肌肉都動起來，該用哪種機器？』教練說：『去門口幫我把車推上來，它的引擎拋錨了。』", "💪 為什麼我每天跑步？因為我發現如果我不跑，生活就會追上我並問我進度到哪了。"),
      "深度閱讀" = c("🧠 讀書就像幫大腦做 SPA。滑手機就像幫大腦做『智商抽脂』。", "📖 我買了一本關於『延遲滿足』的書，我決定下個月再打開來看。"),
      "自然旅遊" = c("🎒 大自然沒有 WiFi，但你會在那裡找到更強的連接。", "🌳 如果你感到焦慮，就去擁抱一棵樹。它不會判斷你，只會給你芬多精和一些螞蟻。"),
      "正念冥想" = c("🧘‍♂️ 冥想就是坐著什麼都不做，直到你發現大腦其實是一個吵雜的菜市場。", "🕊️ 試著專注在呼吸上。如果你覺得呼吸很無聊，那說明你太習慣手機的刺激了。"),
      "專注寫作" = c("⌨️ 寫作是把腦霧變成文字。滑手機則是把文字變成腦霧。", "💡 寫作時時間過得很快；滑手機時命過得很快。"),
      "藝術繪畫" = c("🎨 繪畫不需要完美，只需要大膽把藍色塗在樹上，然後說這是『後現代主義』。", "🖌️ 去畫畫吧！畫出手機螢幕裡買不到的色彩。")
    ),
    "English" = list(
      "Outdoor Sports" = c("🏃‍♂️ I asked my coach: 'Which machine should I use to look amazing?' He said: 'The rowing machine... it's outside in the rain, go!'", "💪 I run because it's hard to be depressed when you're busy gasping for air."),
      "Deep Reading" = c("🧠 Reading is a spa day for your brain. Scrolling is an IQ liposuction.", "📖 I bought a book on procrastination. I'll start it next month."),
      "Nature Travel" = c("🎒 Nature: No WiFi, but you'll find a better connection.", "🌳 Stressed? Hug a tree. It won't judge you, it just offers oxygen and maybe a squirrel."),
      "Mindfulness" = c("🧘‍♂️ Meditation is sitting still and realizing your mind is a very loud chat group.", "🕊️ If breathing feels boring, your dopamine receptors need a serious reboot."),
      "Focused Writing" = c("⌨️ Writing turns brain fog into words. Scrolling turns words into brain fog.", "💡 In writing, time flies. In scrolling, life flies."),
      "Art & Painting" = c("🎨 In art, there are no mistakes, just 'unplanned additions' to your genius.", "🖌️ Go paint! Create a color that no smartphone screen can accurately reproduce.")
    )
  )
  
  reward_seed <- reactiveVal(1)
  observeEvent(input$draw_reward, { reward_seed(sample(1:10000, 1)) })
  
  output$reward_display <- renderUI({
    set.seed(reward_seed())
    current_jokes <- joke_pool[[input$lang]][[input$activity]]
    result_joke <- sample(current_jokes, 1)
    img_url <- paste0("https://loremflickr.com/600/400/funny,cute,animal?random=", reward_seed())
    
    div(style = "text-align: center; animation: fadeIn 0.5s; display: flex; flex-direction: column; align-items: center; justify-content: space-around; height: 100%;",
        h3(t()$reward_msg_prefix, style = "color: #FF6B6B; font-weight: bold; font-size: 28px;"),
        p(result_joke, style = "font-size: 24px; line-height: 1.5; font-weight: bold; padding: 20px; background-color: rgba(78, 205, 196, 0.1); border-radius: 15px; width: 90%;"),
        img(src = img_url, style = "border-radius: 15px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); max-height: 380px; width: auto; border: 4px solid #FF6B6B;")
    )
  })
}

shinyApp(ui, server)