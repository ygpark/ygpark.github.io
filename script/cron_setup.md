# 경제 뉴스 자동 생성 크론탭 설정

## 크론탭 설정 방법

1. 터미널에서 크론탭 편집기 열기:
```bash
crontab -e
```

2. 다음 라인 추가 (매일 오전 9시 실행):
```bash
0 9 * * * /Users/ghostyak/Documents/github/hugo-boilerplate/script/generate_economy_post.sh >> /Users/ghostyak/Documents/github/hugo-boilerplate/logs/cron.log 2>&1
```

### 다른 시간대 옵션:

- 매일 오전 6시: `0 6 * * *`
- 매일 오후 6시: `0 18 * * *`
- 매일 정오: `0 12 * * *`
- 평일만 오전 9시: `0 9 * * 1-5`
- 매 6시간마다: `0 */6 * * *`

## Git 자동화 옵션

### 기본 설정 (빌드 + 커밋 + 푸시 모두 실행)
```bash
0 9 * * * /Users/ghostyak/Documents/github/hugo-boilerplate/script/generate_economy_post.sh >> /Users/ghostyak/Documents/github/hugo-boilerplate/logs/cron.log 2>&1
```

### 커밋만 하고 푸시는 하지 않기
```bash
0 9 * * * AUTO_PUSH=false /Users/ghostyak/Documents/github/hugo-boilerplate/script/generate_economy_post.sh >> /Users/ghostyak/Documents/github/hugo-boilerplate/logs/cron.log 2>&1
```

### Git 작업 완전히 비활성화
```bash
0 9 * * * AUTO_GIT=false /Users/ghostyak/Documents/github/hugo-boilerplate/script/generate_economy_post.sh >> /Users/ghostyak/Documents/github/hugo-boilerplate/logs/cron.log 2>&1
```

## 크론탭 확인

현재 설정된 크론탭 확인:
```bash
crontab -l
```

## 로그 확인

생성된 로그 확인:
```bash
# 최신 로그 보기
tail -f ~/Documents/github/hugo-boilerplate/logs/cron.log

# 스크립트 자체 로그
ls -lt ~/Documents/github/hugo-boilerplate/logs/economy_post_*.log
```

## 문제 해결

### Claude Code 권한 문제
스크립트 실행 시 Claude Code가 웹 검색 권한을 요청할 수 있습니다.
초기 수동 실행으로 권한을 허용한 후 크론탭을 설정하세요:
```bash
./script/generate_economy_post.sh
```

### PATH 문제
크론 환경에서 claude 명령을 찾지 못하는 경우, 스크립트에 전체 경로 추가:
```bash
# which claude 명령으로 경로 확인
which claude
```

스크립트 수정:
```bash
# generate_economy_post.sh 파일에서
CLAUDE_PATH="/usr/local/bin/claude"  # 실제 경로로 변경
$CLAUDE_PATH <<EOF
...
```