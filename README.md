# Hugo Boilerplate — 사용법

간단히 `Makefile`로 Hugo 개발 서버와 빌드를 관리할 수 있도록 설정했습니다. pnpm을 사용하는 개발자에 맞춰 제작되었습니다.

## 주요 명령

- make dev — 로컬 개발 서버 시작 (초안 포함)
- make serve — 프로덕션 유사 서버 시작
- make build — 정적 사이트 빌드 (./public)
- make install — pnpm 의존성 설치
- make clean — 빌드 아티팩트 제거
- make ci-build — CI용 클린 빌드

## 예시: 개발 시작

```bash
# pnpm으로 종속성 설치
pnpm install

# 개발 서버 시작
make dev
```

## 권장 pnpm 스크립트 (package.json)

아래 스크립트들을 `package.json`에 추가하면 `make dev` 전에 필요한 빌드/워치 작업을 자동화할 수 있습니다:

```json
"scripts": {
  "build:css": "tailwindcss -i assets/css/main.css -o static/css/main.css --minify",
  "watch:css": "tailwindcss -i assets/css/main.css -o static/css/main.css --watch",
  "dev": "pnpm run watch:css"
}
```

`Makefile`의 `dev` 타깃은 `package.json`이 존재하면 `pnpm install`을 자동으로 시도합니다.

## 환경 변수

- PORT — 개발 서버 포트 (기본값: 1313)
- BIND — 바인드 주소 (기본값: 127.0.0.1)

예:

```bash
PORT=8080 make dev
```

## CI 팁

CI에서는 `make ci-build`를 호출하여 깨끗한 상태에서 빌드하도록 권장합니다.
