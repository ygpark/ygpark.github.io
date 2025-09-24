#!/bin/zsh

# 경제 뉴스 포스트 자동 생성 스크립트
# Claude Code를 이용해 경제 뉴스를 수집하고 Hugo 포스트로 저장

# 스크립트 경로 설정
PROJECT_ROOT="/var/www/hugo-boilerplate"
SCRIPT_DIR="$PROJECT_ROOT/script"
POSTS_DIR="$PROJECT_ROOT/content/posts"
cd "$SCRIPT_DIR" || { echo "프로젝트 디렉토리로 이동 실패"; exit 1; }


# 날짜 설정
DATE=$(date +"%Y-%m-%d")
YEAR=$(date +"%Y")
MONTH=$(date +"%m")
DAY=$(date +"%d")
TIME=$(date +"%H:%M:%S")
POST_FILE="$POSTS_DIR/${DATE}-economy.md"

# 로그 함수
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "경제 뉴스 포스트 생성 시작"

# 포스트 디렉토리 생성
mkdir -p "$POSTS_DIR"

# 포스트 파일 존재 확인
if [ -f "$POST_FILE" ]; then
    log "WARNING: 포스트 파일이 이미 존재합니다: $POST_FILE"
    log "기존 파일을 덮어쓰지 않습니다. 스크립트를 종료합니다."
    exit 1
fi

# Hugo 프론트매터 추가
cat > "$POST_FILE" << FRONTMATTER
---
title: "${YEAR}년 ${MONTH}월 ${DAY}일 경제 뉴스 TOP 10"
date: ${DATE}T${TIME}+09:00
draft: false
categories:
  - 경제
tags:
  - 경제
summary: "오늘의 주요 경제 뉴스와 시장 동향을 정리했습니다."
---

FRONTMATTER

log "포스트 파일 생성 완료: $POST_FILE"

