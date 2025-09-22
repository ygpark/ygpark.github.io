#!/bin/zsh

# 경제 뉴스 포스트 자동 생성 스크립트
# Claude Code를 이용해 경제 뉴스를 수집하고 Hugo 포스트로 저장

# 스크립트 경로 설정
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROMPT_FILE="$SCRIPT_DIR/_prompt_post_economy.md"
POSTS_DIR="$PROJECT_ROOT/content/posts"

# 날짜 설정
DATE=$(date +"%Y-%m-%d")
YEAR=$(date +"%Y")
MONTH=$(date +"%m")
DAY=$(date +"%d")
TIME=$(date +"%H:%M:%S")
POST_FILE="$POSTS_DIR/${DATE}-economy.md"

# 로그 디렉토리 생성
LOG_DIR="$PROJECT_ROOT/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/economy_post_$(date +%Y%m%d_%H%M%S).log"

# 로그 함수
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "경제 뉴스 포스트 생성 시작"

# Claude Code 실행 가능 여부 확인
if ! command -v claude &> /dev/null; then
    log "ERROR: Claude Code가 설치되어 있지 않습니다."
    log "설치 방법: https://docs.anthropic.com/en/docs/claude-code/installation"
    exit 1
fi

# 프롬프트 파일 존재 확인
if [ ! -f "$PROMPT_FILE" ]; then
    log "ERROR: 프롬프트 파일을 찾을 수 없습니다: $PROMPT_FILE"
    exit 1
fi

# 포스트 디렉토리 생성
mkdir -p "$POSTS_DIR"

log "RSS 피드 다운로드 중..."

# RSS 피드 다운로드 스크립트 실행
"$SCRIPT_DIR/download_rss_feeds.sh" 2>> "$LOG_FILE"
if [ $? -ne 0 ]; then
    log "ERROR: RSS 피드 다운로드 실패"
    exit 1
fi

RSS_FILE="$SCRIPT_DIR/combined_rss_feeds.xml"
if [ ! -f "$RSS_FILE" ]; then
    log "ERROR: RSS 피드 파일을 찾을 수 없습니다: $RSS_FILE"
    exit 1
fi

log "Claude Code로 뉴스 분석 중..."

# Claude Code 실행하여 컨텐츠 생성
# 프롬프트와 RSS 데이터를 함께 전달
PROMPT_CONTENT=$(cat "$PROMPT_FILE")
RSS_CONTENT=$(cat "$RSS_FILE")

# 프롬프트와 RSS 내용을 결합하여 전달
COMBINED_INPUT="$PROMPT_CONTENT

=== RSS 피드 데이터 시작 ===
$RSS_CONTENT
=== RSS 피드 데이터 끝 ==="

CONTENT=$(echo "$COMBINED_INPUT" | claude 2>> "$LOG_FILE")

# Claude Code 실행 성공 확인
if [ $? -ne 0 ] || [ -z "$CONTENT" ]; then
    log "ERROR: Claude Code 실행 실패"
    exit 1
fi

# RSS 피드 파일 정리
rm -f "$RSS_FILE"

log "컨텐츠 생성 완료"

# Hugo 프론트매터 추가
cat > "$POST_FILE" << FRONTMATTER
---
title: "경제 뉴스 큐레이션 - ${YEAR}년 ${MONTH}월 ${DAY}일"
date: ${DATE}T${TIME}+09:00
draft: false
categories:
  - 경제
  - 뉴스
tags:
  - 경제동향
  - 금융시장
  - 코인
  - 주식
  - 금
summary: "오늘의 주요 경제 뉴스와 시장 동향을 정리했습니다."
---

FRONTMATTER

# Claude가 생성한 컨텐츠 추가
echo "$CONTENT" >> "$POST_FILE"

# 푸터 추가
cat >> "$POST_FILE" << FOOTER

---

*이 포스트는 자동으로 생성되었습니다. 최신 정보는 원문 출처를 확인해 주세요.*
FOOTER

log "포스트 파일 생성 완료: $POST_FILE"

# Google 링크 추가 (기존 스크립트 활용)
if [ -f "$SCRIPT_DIR/add_google_links.py" ]; then
    log "Google 검색 링크 추가 중..."
    python3 "$SCRIPT_DIR/add_google_links.py" "$POST_FILE" 2>> "$LOG_FILE"
    if [ $? -eq 0 ]; then
        log "Google 검색 링크 추가 완료"
    else
        log "WARNING: Google 검색 링크 추가 실패"
    fi
fi

# Hugo 사이트 빌드
log "Hugo 사이트 빌드 중..."
cd "$PROJECT_ROOT"
hugo --minify 2>> "$LOG_FILE"
if [ $? -eq 0 ]; then
    log "Hugo 빌드 완료"
else
    log "ERROR: Hugo 빌드 실패"
    exit 1
fi

# Git 자동 커밋 및 푸시
if [ "${AUTO_GIT:-true}" != "false" ]; then
    log "Git 작업 시작..."
    cd "$PROJECT_ROOT"

    # 변경사항 확인
    if git diff --quiet && git diff --cached --quiet; then
        log "변경사항이 없습니다."
    else
        # 모든 변경사항 추가 (포스트 파일과 빌드된 public 폴더 포함)
        git add "$POST_FILE" 2>> "$LOG_FILE"
        git add public/ 2>> "$LOG_FILE"

        # 커밋
        COMMIT_MSG="자동 생성: 경제 뉴스 큐레이션 - $DATE"
        git commit -m "$COMMIT_MSG" 2>> "$LOG_FILE"

        if [ $? -eq 0 ]; then
            log "Git 커밋 완료: $COMMIT_MSG"

            # 푸시 (AUTO_PUSH 환경변수로 제어, 기본값 true)
            if [ "${AUTO_PUSH:-true}" != "false" ]; then
                log "원격 저장소로 푸시 중..."
                git push 2>> "$LOG_FILE"
                if [ $? -eq 0 ]; then
                    log "Git 푸시 완료"
                else
                    log "WARNING: Git 푸시 실패 - 네트워크나 인증 문제일 수 있습니다"
                    log "수동으로 'git push'를 실행해주세요"
                fi
            else
                log "AUTO_PUSH가 비활성화되어 푸시를 건너뜁니다"
            fi
        else
            log "WARNING: Git 커밋 실패"
        fi
    fi
else
    log "AUTO_GIT이 비활성화되어 Git 작업을 건너뜁니다"
fi

log "경제 뉴스 포스트 생성 완료"
log "----------------------------------------"

exit 0