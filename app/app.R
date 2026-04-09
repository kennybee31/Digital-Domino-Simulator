# ==============================================================================
# Project: Digital Domino - Life Regeneration Simulator (STRICT FIX)
# 指示：嚴格保留 V10 佈局與配色，僅修正 X 軸標籤顯示問題
# ==============================================================================

if (!require("pacman")) install.packages("pacman")
pacman::p_load(shiny, bslib, tidyverse, scales, shinyjs, shinyWidgets, munsell)

# 1. 雙語字典 - 保持不變
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
    disc_title = "⚠️ 數據來源與合規宣告",
    disc_1 = "📊 數據：Kaggle 全球行為數據集與 RescueTime 統計。",
    disc_2 = "🧮 模型：PRA 概率風險評估，推演 30 天累積效應。",
    disc_3 = "🛡️ 規範：遵從 ISO 42001 倫理規範。數據僅供參考，非醫療診斷。",
    disc_4 = "📝 內容：內建幽默小語由團隊基於公有領域精選改寫，確保無偏見且符合心理安全。",
    disc_5 = "🖼️ 圖片：採用 LoremFlickr 隨機 API (標籤限制：funny, cute, animal)。",
    plot_title = "📉 10 大骨牌連鎖效應 (漸層能量波浪)",
    risk_title = "🏎️ 系統過載：大腦引擎指數",
    reward_title = "🎉 專屬生命再生笑話與圖卡",
    dominoes = c("視力乾澀", "頸椎僵硬", "睡眠碎裂", "腦霧現象", "專注崩盤", 
                 "情緒暴躁", "社交退縮", "體態走鐘", "決策疲勞", "深度思考喪失"),
    status_stand = "健康 (安全)",
    status_fall = "崩潰 (倒下)",
    engine_safe = "✨🟢 引擎運轉順暢：轉速正常，持續進！",
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

# 2. 主題與樣式 - 恢復您喜歡的 Minty 風格與佈局
lively_theme <- bs_theme(version = 5, bootswatch = "minty")
custom_css <- "
  .card { border-radius: 20px; box-shadow: 0 8px 15px rgba(0,0,0,0.05); }
  .card-header { background: #4ECDC4; color: white; font-weight: bold; }
  .disclaimer-box { background-color: white; padding: 15px; border-left: 5px solid #FF6B6B; font-size: 0.8rem; }
"

ui <- fluidPage(
  theme = lively_theme,
  useShinyjs(),
  tags$head(tags$style(HTML(custom_css))),
  div(style = "display: flex; justify-content: space-between; align-items: center; padding: 20px 0;",
      h2(textOutput("app_title"), style = "color: #4ECDC4;"),
      radioGroupButtons("lang", choices = c("中文", "English"), status = "primary", size = "sm")),
  uiOutput("main_ui")
)

server <- function(input, output, session) {
  t <- reactive({ i18n[[input$lang]] })
  output$app_title <- renderText({ t()$app_title })
  
  output$main_ui <- renderUI({
    page_sidebar(
      sidebar = sidebar(
        width = 350, title = t()$sb_title,
        sliderInput("hours", t()$lb_hours, min = 0, max = 24, value = 6, step = 0.5),
        sliderInput("pickups", t()$lb_pickups, min = 10, max = 250, value = 50, step = 5),
        hr(),
        pickerInput("activity", t()$lb_act, choices = t()$choices_act),
        sliderInput("act_hours", t()$lb_act_hrs, min = 0.5, max = 12, value = 1, step = 0.5),
        actionButton("draw_reward", t()$btn_reward, class = "btn-danger w-100 btn-lg"),
        hr(),
        div(class = "disclaimer-box", h6(t()$disc_title), p(t()$disc_1), p(t()$disc_2), p(t()$disc_3), p(t()$disc_4), p(t()$disc_5))
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
    lvl <- min(100, (input$hours * 30 / 360) * 60 + (input$pickups * 30 / 6000) * 40)
    list(overload = lvl)
  })
  
  # --- 核心修正處：波浪圖標籤修復 ---
  output$wave_plot <- renderPlot({
    res <- metrics(); lvl <- res$overload; x_seq <- seq(1, 10, length.out = 300)
    y_seq <- pmax(0, pmin(100, (100 - (lvl * ((x_seq - 1) / 9))) + sin(x_seq * (1 + lvl/20)) * (lvl/4)))
    df_wave <- data.frame(Stage = x_seq, Health = y_seq)
    
    ggplot(df_wave) +
      geom_segment(aes(x = Stage, xend = Stage, y = 0, yend = Health, color = Stage), size = 2.5) +
      scale_color_gradientn(colors = c("#4ECDC4", "#FDCB6E", "#FF6B6B")) +
      geom_text(data = data.frame(x = 1:10, label = t()$dominoes), 
                aes(x = x, y = -5, label = label), angle = 45, hjust = 1, size = 5.5, fontface = "bold") +
      coord_cartesian(ylim = c(-30, 110), clip = "off") + # 修改1：clip = 'off' 允許文字超出邊界
      theme_void() +
      theme(plot.margin = margin(20, 10, 80, 10), legend.position = "none") # 修改2：增加底部邊距 (80)
  })
  
  # 引擎與笑話邏輯 - 保持 V10 版本不變
  output$engine_display <- renderUI({
    lvl <- metrics()$overload
    if(lvl > 70) { col <- "#FF6B6B"; txt <- t()$engine_erupt; emo <- "💥🔥🚗" 
    } else if(lvl > 30) { col <- "#FDCB6E"; txt <- t()$engine_warn; emo <- "⚠️🌡️🚗"
    } else { col <- "#4ECDC4"; txt <- t()$engine_safe; emo <- "✨🟢🚗" }
    div(style = "text-align: center; height: 100%; display: flex; flex-direction: column; justify-content: space-around;",
        plotOutput("rpm", height = "250px"),
        div(style = "font-size: 80px;", emo), p(txt, style = paste0("font-size: 20px; font-weight: bold; color: ", col, ";")))
  })
  
  output$rpm <- renderPlot({
    lvl <- metrics()$overload; blocks <- data.frame(x = seq(2, 98, by = 4), y = 1)
    blocks$color <- ifelse(blocks$x <= lvl, ifelse(blocks$x > 70, "#FF6B6B", ifelse(blocks$x > 30, "#FDCB6E", "#4ECDC4")), "#E0E0E0")
    ggplot(blocks, aes(x = x, y = y)) + geom_col(aes(fill = color), width = 3) + scale_fill_identity() +
      annotate("text", x = 50, y = 0.5, label = paste0(round(lvl, 1), "%"), size = 15, fontface = "bold") + theme_void()
  })
  
  reward_seed <- reactiveVal(1)
  observeEvent(input$draw_reward, { reward_seed(sample(1:10000, 1)) })
  output$reward_display <- renderUI({
    set.seed(reward_seed()); joke <- sample(list("中文" = c("讀書是 SPA，滑手機是智商抽脂。", "買了延遲滿足的書，決定下個月看。"), "English" = c("Reading is a spa, scrolling is IQ liposuction.", "Bought a book on procrastination, starting next month."))[[input$lang]], 1)
    div(style = "text-align: center; display: flex; flex-direction: column; justify-content: space-around; height: 100%;",
        h3(t()$reward_msg_prefix), p(joke, style = "font-size: 22px; font-weight: bold; background: #F0FBF9; padding: 15px; border-radius: 15px;"),
        img(src = paste0("https://loremflickr.com/600/400/funny,animal?random=", reward_seed()), style = "max-height: 350px; border-radius: 15px; border: 4px solid #FF6B6B;"))
  })
}
shinyApp(ui, server)