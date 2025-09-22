#!/bin/zsh

# RSS 피드 다운로드 스크립트
# 여러 경제 뉴스 RSS 피드를 다운로드하여 하나의 파일로 병합

# set -e 제거 (부분 실패 허용)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMP_DIR="$SCRIPT_DIR/rss_feeds"
OUTPUT_FILE="$SCRIPT_DIR/combined_rss_feeds.xml"

# 임시 디렉토리 생성
mkdir -p "$TEMP_DIR"

# RSS 피드 URL 목록
RSS_FEEDS=(
    "https://www.ft.com/rss/home"
    "https://feeds.a.dj.com/rss/RSSMarketsMain.xml"
    "https://feeds.bloomberg.com/markets/news.rss"
    "https://feeds.reuters.com/reuters/businessNews"
    "http://feeds.marketwatch.com/marketwatch/topstories/"
    "https://www.cnbc.com/id/100003114/device/rss/rss.html"
    "https://www.forbes.com/real-time/feed2/"
    "https://www.economist.com/rss.xml"
    "http://feeds.bbci.co.uk/news/business/rss.xml"
    "http://rss.cnn.com/rss/money_latest.rss"
)

# 시작 태그
echo '<?xml version="1.0" encoding="UTF-8"?>' > "$OUTPUT_FILE"
echo '<combined_feeds>' >> "$OUTPUT_FILE"

# 각 RSS 피드 다운로드
i=0
for FEED_URL in "${RSS_FEEDS[@]}"; do
    FEED_FILE="$TEMP_DIR/feed_$i.xml"

    echo "Downloading feed $((i+1)): $FEED_URL"

    # curl로 피드 다운로드 (타임아웃 15초, 리다이렉트 따라가기, User-Agent 설정)
    if curl -L -s --max-time 15 -H "User-Agent: Mozilla/5.0 (compatible; RSS Reader)" "$FEED_URL" -o "$FEED_FILE" 2>/dev/null; then
        # XML 헤더 제거하고 피드 내용 추가
        echo "<feed source=\"$FEED_URL\">" >> "$OUTPUT_FILE"
        # XML 선언 제거하고 내용 추가
        sed '1s/^<?xml[^>]*?>//g' "$FEED_FILE" >> "$OUTPUT_FILE"
        echo "</feed>" >> "$OUTPUT_FILE"
        echo "  ✓ Downloaded successfully"
    else
        echo "  ✗ Failed to download"
    fi
    ((i++))
done

# 종료 태그
echo '</combined_feeds>' >> "$OUTPUT_FILE"

# 임시 디렉토리 정리
rm -rf "$TEMP_DIR"

echo "All feeds combined into: $OUTPUT_FILE"

# 성공 종료 코드 반환 (일부 피드 실패해도 계속 진행)
exit 0