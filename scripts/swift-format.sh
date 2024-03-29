if [[ -z "${TRAVIS}" ]]; then
    tools/swiftformat . --cache ignore --exclude **/Pods --exclude **/R.generated.swift
fi
