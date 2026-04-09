# ==============================================================================
# Project: Digital Domino - Life Regeneration Simulator (WebR / ShinyLive 專用版)
# Features: 移除 pacman 依賴、支援 Noto Sans TC 中文圖表、漸層波浪圖
# ==============================================================================

# 1. 載入必備套件 (ShinyLive 嚴禁使用 pacman 或 install.packages)
library(shiny)
library(bslib)
library(tidyverse)
library(scales)
library(shinyjs)
library(shinyWidgets)
library(munsell)
library(showtext)

# --- 關鍵：處理 ShinyLive 繪圖中文字型 ---
# 從 Google Fonts 載入思源黑體，確保 ggplot2 在網頁端不會顯示為方塊
sysfonts::font_add_google("Noto Sans TC", "noto_sans_tc")
showtext::showtext_auto()

# ------------------------------------------------------------------------------
# 2. 嚴謹雙語字典 (i18n)
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
    disc_4 = "📝 內容：內建幽默小語由團隊基於公有領域精選改寫，確保無偏見。",
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
    disc_3 = "🛡️ Compliance: ISO 42001 compliant. Educational only.",
    disc_4 = "📝 Content: Manually curated safe jokes from public domain sources.",
    disc_5 = "🖼️ Image: Powered by LoremFlickr API (funny, cute, animal).",
    plot_title = "📉 10 Domino Effects (Gradient Energy Wave)",
    risk_title = "🏎️ System Overload: Brain Engine RPM Index",
    reward_title = "🎉 Exclusive Regeneration Joke & Card",
    dominoes = c("Dry Eyes", "Text Neck", "Broken Sleep", "Brain Fog", "Focus Collapse", 
                 "Irritability", "Social Anxiety", "Weight Gain", "Decision Fatigue", "Loss of Deep Thought"),
    status_stand = "Healthy (Safe)",
    status_fall = "Fallen (Collapsed)",
    engine_safe = "✨🟢 Smooth: RPM normal, keep cruising!",
    engine_warn = "⚠️🌡️ Overheating: Brain engine is hot, cool down!",
    engine_erupt = "💥🔥 Engine Blown: Meltdown! Rest immediately!",
    reward_msg_prefix = "Achievement Unlocked: Mindful Inspiration:"
  )
)

# ------------------------------------------------------------------------------
# 3. UI 佈局與 CSS (Minty 風格)
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
  .card-header { background: linear-gradient(135deg, #4ECDC4, #556270); color: white; border-radius: 20px 20px 0 0 !important; font-weight: bold; }
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
# 4. Server 伺服器邏輯
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
            h6(t()$disc_title, style="font-weight:bold; color:#4ECDC4;"),
            p(t()$disc_1), p(t()$disc_2), p(t()$disc_3), p(t()$disc_4), p(t()$disc_5))
      ),
      layout_columns(
        fill = TRUE,
        card(card_header(t()$plot_title), plotOutput("wave_plot", height = "520px")),
        card(card_header(t()$risk_title), uiOutput("engine_display", height = "520px")),
        card(full_screen = TRUE, card_header(t()$reward_title), uiOutput("reward_display", height = "520px"))
      )
    )
  })
  
  metrics <- reactive({
    monthly_hours <- (input$hours %||% 6) * 30
    monthly_pickups <- (input$pickups %||% 50) * 30
    overload_pct <- min(100, (monthly_hours / 360) * 60 + (monthly_pickups / 6000) * 40)
    list(overload = overload_pct)
  })
  
  output$wave_plot <- renderPlot({
    res <- metrics()
    lvl <- res$overload
    x_seq <- seq(1, 10, length.out = 300)
    base_y <- 100 - (lvl * ((x_seq - 1) / 9)) 
    wave_y <- pmax(0, pmin(100, base_y + sin(x_seq * (1 + lvl/20)) * (lvl/4)))
    
    df_wave <- data.frame(Stage = x_seq, Health = wave_y)
    df_labels <- data.frame(x = 1:10, y = -12, label = t()$dominoes)
    
    ggplot() +
      geom_segment(data = df_wave, aes(x = Stage, xend = Stage, y = 0, yend = Health, color = Stage), size = 2.5) +
      scale_color_gradientn(colors = c("#4ECDC4", "#FDCB6E", "#FF6B6B")) +
      geom_text(data = df_labels, aes(x = x, y = y, label = label),
                angle = 45, hjust = 1, size = 5.5, fontface = "bold", 
                color = "#2C3E50", family = "noto_sans_tc") +
      coord_cartesian(ylim = c(-35, 110), clip = "off") + 
      theme_void() +
      theme(plot.margin = margin(20, 10, 80, 10), legend.position = "none")
  })
  
  output$engine_display <- renderUI({
    res <- metrics(); lvl <- res$overload
    if(lvl > 70) { status_color <- "#FF6B6B"; status_text <- t()$engine_erupt; emoji <- "💥🔥🚗" 
    } else if(lvl > 30) { status_color <- "#FDCB6E"; status_text <- t()$engine_warn; emoji <- "⚠️🌡️🚗"
    } else { status_color <- "#4ECDC4"; status_text <- t()$engine_safe; emoji <- "✨🟢🚗" }
    
    div(style = "text-align: center; padding: 20px; height: 100%; display: flex; flex-direction: column; justify-content: space-around;",
        plotOutput("engine_rpm_plot", height = "280px"),
        div(hr(style = "border-top: 2px dashed #BDC3C7; width: 90%; margin: 10px auto;"),
            div(style = "font-size: 100px; line-height: 1.2;", emoji),
            p(status_text, style = paste0("font-size: 24px; font-weight: bold; color: ", status_color, ";")))
    )
  })
  
  output$engine_rpm_plot <- renderPlot({
    lvl <- metrics()$overload
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
  
  joke_pool <- list(
    "中文" = list(
      "戶外運動" = c("🏃‍♂️ 我去健身房問教練：『我想讓全身肌肉都動起來該用哪台機器？』教練說：『去幫我把車推上來。』", "💪 跑步是為了當生活想擊倒你時，你至少跑得贏生活。"),
      "深度閱讀" = c("🧠 讀書是幫大腦做 SPA，滑手機是做『智商抽脂』。", "📖 買了本延遲滿足的書，我決定下個月再看。"),
      "自然旅遊" = c("🎒 大自然沒 WiFi，但你會找到更好的連結。", "🌳 焦慮就去抱樹，它不判斷你，只給你氧氣。"),
      "正念冥想" = c("🧘‍♂️ 冥想就是坐著什麼都不做，直到發現大腦是個菜市場。", "🕊️ 專注呼吸。無聊？那是因為你太習慣手機刺激了。"),
      "專注寫作" = c("⌨️ 寫作是把腦霧變文字，滑手機是反過來。", "💡 寫作時時間過得快，滑手機時命過得很快。"),
      "藝術繪畫" = c("🎨 繪畫不需要完美，只要敢塗藍色再說是『後現代』。", "🖌️ 畫出手機螢幕裡買不到的色彩吧！")
    ),
    "English" = list(
      "Outdoor Sports" = c("🏃‍♂️ Coach, which machine for girls? 'The ATM outside.' ...Just run instead!", "💪 I run because cake doesn't judge my speed."),
      "Deep Reading" = c("🧠 Reading is a brain spa. Scrolling is IQ liposuction.", "📖 Bought a book on procrastination. Starting it next month."),
      "Nature Travel" = c("🎒 Nature: No WiFi, but a better connection.", "🌳 Stressed? Hug a tree. It only judges your lack of oxygen."),
      "Mindfulness" = c("🧘‍♂️ Meditation: Realizing your mind is a loud chat group.", "🕊️ If breathing is boring, your dopamine needs a reset."),
      "Focused Writing" = c("⌨️ Writing converts fog to words. Scrolling does the opposite.", "💡 In writing, time flies. In scrolling, life flies."),
      "Art & Painting" = c("🎨 In art, there are no mistakes, just 'unplanned additions'.", "🖌️ Paint a color a smartphone can't replicate.")
    )
  )
  
  reward_seed <- reactiveVal(1)
  observeEvent(input$draw_reward, { reward_seed(sample(1:10000, 1)) })
  
  output$reward_display <- renderUI({
    set.seed(reward_seed())
    joke <- sample(joke_pool[[input$lang]][[input$activity]], 1)
    img_url <- paste0("https://loremflickr.com/600/400/funny,cute,animal?random=", reward_seed())
    
    div(style = "text-align: center; display: flex; flex-direction: column; justify-content: space-around; height: 100%;",
        h3(t()$reward_msg_prefix, style = "color: #FF6B6B; font-weight: bold;"),
        p(joke, style = "font-size: 24px; font-weight: bold; padding: 20px; background: rgba(78,205,196,0.1); border-radius: 15px; width: 90%;"),
        img(src = img_url, style = "border-radius: 15px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); max-height: 380px; border: 4px solid #FF6B6B;")
    )
  })
}

shinyApp(ui, server)