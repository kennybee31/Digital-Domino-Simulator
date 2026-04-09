# ==============================================================================
# Project: Digital Domino - Life Regeneration Simulator (Final WebR Edition)
# 特色：Plotly 分段漸層技術 (解決中文亂碼 + 漸層海浪)，其餘嚴格保持不變
# ==============================================================================

# 1. 載入必備套件
library(shiny)
library(bslib)
library(tidyverse)
library(plotly)
library(shinyjs)
library(shinyWidgets)

# ------------------------------------------------------------------------------
# 2. 嚴謹雙語字典 (i18n) - 嚴格保留 V10 內容與合規宣告
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
# 3. UI 佈局 - 嚴格保留 V10 風格
# ------------------------------------------------------------------------------
ui <- fluidPage(
  theme = bs_theme(version = 5, bootswatch = "minty"),
  useShinyjs(),
  
  div(style = "display: flex; justify-content: space-between; align-items: center; padding: 20px 0;",
      h2(textOutput("app_title"), style = "margin: 0; font-weight: 800; color: #4ECDC4;"),
      radioGroupButtons("lang", choices = c("中文", "English"), status = "primary", size = "sm")
  ),
  
  uiOutput("main_ui")
)

server <- function(input, output, session) {
  t <- reactive({ i18n[[input$lang]] })
  output$app_title <- renderText({ t()$app_title })
  
  output$main_ui <- renderUI({
    page_sidebar(
      sidebar = sidebar(
        width = 350,
        title = t()$sb_title,
        sliderInput("hours", t()$lb_hours, min = 0, max = 24, value = 6, step = 0.5),
        sliderInput("pickups", t()$lb_pickups, min = 10, max = 250, value = 50, step = 5),
        hr(),
        pickerInput("activity", t()$lb_act, choices = t()$choices_act),
        sliderInput("act_hours", t()$lb_act_hrs, min = 0.5, max = 12, value = 1, step = 0.5),
        actionButton("draw_reward", t()$btn_reward, class = "btn-danger w-100 btn-lg"),
        hr(),
        div(style="background: white; padding:15px; border-left:5px solid #4ECDC4; font-size:0.8rem; color:#7f8c8d;",
            h6(t()$disc_title), p(t()$disc_1), p(t()$disc_2), p(t()$disc_3), p(t()$disc_4), p(t()$disc_5))
      ),
      layout_columns(
        fill = TRUE,
        card(card_header(t()$plot_title), plotlyOutput("wave_plot", height = "500px")),
        card(card_header(t()$risk_title), uiOutput("engine_display", height = "500px")),
        card(full_screen = TRUE, card_header(t()$reward_title), uiOutput("reward_display", height = "500px"))
      )
    )
  })
  
  metrics <- reactive({
    lvl <- min(100, (input$hours * 30 / 360) * 60 + (input$pickups * 30 / 6000) * 40)
    list(overload = lvl)
  })
  
  # ------------------------------------------------------------------------------
  # 修改重點 1：分段漸層波浪圖 (Plotly 渲染，無亂碼)
  # ------------------------------------------------------------------------------
  output$wave_plot <- renderPlotly({
    lvl <- metrics()$overload
    # 建立 10 個區段的漸層色
    cols <- colorRampPalette(c("#4ECDC4", "#FDCB6E", "#FF6B6B"))(10)
    
    p <- plot_ly()
    
    # 分成 10 個 Trace 來實現從左到右的漸層
    for(i in 1:10) {
      # 每個 Trace 負責一個 X 軸範圍 (確保海浪連貫)
      x_sub <- seq(i - 0.5, i + 0.5, length.out = 20)
      if(i == 1) x_sub <- seq(1, 1.5, length.out = 20)
      if(i == 10) x_sub <- seq(9.5, 10, length.out = 20)
      
      y_sub <- pmax(0, pmin(100, (100 - (lvl * ((x_sub - 1) / 9))) + sin(x_sub * (1 + lvl/20)) * (lvl/4)))
      
      p <- p %>% add_trace(
        x = x_sub, y = y_sub,
        type = 'scatter', mode = 'lines',
        fill = 'tozeroy', 
        fillcolor = paste0(cols[i], "AA"), # 半透明填充
        line = list(color = cols[i], width = 4),
        hoverinfo = 'none', showlegend = FALSE
      )
    }
    
    p %>% layout(
      xaxis = list(
        title = "", # 移除 x_seq 標題
        tickvals = 1:10,
        ticktext = t()$dominoes,
        tickangle = -45,
        fixedrange = TRUE,
        showgrid = FALSE
      ),
      yaxis = list(
        title = ifelse(input$lang=="中文", "身心能量 %", "Energy %"), # 修正 y_seq 標題
        range = c(0, 110), 
        fixedrange = TRUE, 
        showgrid = TRUE,
        gridcolor = "#f0f0f0"
      ),
      margin = list(b = 100, l = 60, r = 30, t = 40)
    ) %>%
      config(displayModeBar = FALSE)
  })
  
  # ------------------------------------------------------------------------------
  # 其餘組件 - 嚴格保持不變 (引擎與笑話系統)
  # ------------------------------------------------------------------------------
  output$engine_display <- renderUI({
    lvl <- metrics()$overload
    if(lvl > 70) { col <- "#FF6B6B"; txt <- t()$engine_erupt; emo <- "💥🔥🚗" 
    } else if(lvl > 30) { col <- "#FDCB6E"; txt <- t()$engine_warn; emo <- "⚠️🌡️🚗"
    } else { col <- "#4ECDC4"; txt <- t()$engine_safe; emo <- "✨🟢🚗" }
    
    div(style = "text-align: center; height: 100%; display: flex; flex-direction: column; justify-content: space-around;",
        plotOutput("engine_rpm_plot", height = "280px"),
        div(style = "font-size: 90px;", emo),
        p(txt, style = paste0("font-size: 24px; font-weight: bold; color: ", col, ";"))
    )
  })
  
  output$engine_rpm_plot <- renderPlot({
    lvl <- metrics()$overload
    blocks <- data.frame(x = seq(2, 98, by = 4), y = 1)
    blocks$color <- ifelse(blocks$x <= lvl, ifelse(blocks$x > 70, "#FF6B6B", ifelse(blocks$x > 30, "#FDCB6E", "#4ECDC4")), "#E0E0E0")
    ggplot(blocks, aes(x = x, y = y)) +
      geom_col(aes(fill = color), width = 3) + scale_fill_identity() +
      annotate("text", x = 50, y = 0.5, label = paste0(round(lvl, 1), "%"), size = 20, fontface = "bold") +
      theme_void()
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
        img(src = img_url, style = "border-radius: 15px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); max-height: 380px; width: auto; border: 4px solid #FF6B6B;")
    )
  })
}

shinyApp(ui, server)