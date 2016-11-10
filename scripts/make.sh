#! /bin/bash

# Makes release/github-to-swamp.zip 

function main {
    local pdir=$(dirname $(dirname 0))

    local release_dir="$pdir/release"
    mkdir -p "$release_dir"

    (
        cd "$release_dir"
    
            wget https://pypi.python.org/packages/ea/03/92d3278bf8287c5caa07dbd9ea139027d5a3592b0f4d14abf072f890fab2/requests-2.11.1-py2.py3-none-any.whl#md5=b4269c6fb64b9361288620ba028fd385 && \
                unzip requests-2.11.1-py2.py3-none-any.whl
        if [[ ! -d "requests" ]]; then
            echo "$failed to get 'requests' library" && exit 1;
        fi


        wget https://github.com/vamshikr/swamp-python-api/archive/master.zip \
             -O swamp-python-api-master.zip && \
            unzip swamp-python-api-master.zip && \
            cp -r swamp-python-api-master/src/swamp_api .
        
        if [[ ! -d "swamp_api" ]]; then
            echo "$failed to get 'swamp_api (https://github.com/vamshikr/swamp-python-api)' library" && exit 1;
        fi

        cp ../src/lambda_function.py ../src/github.py ../resources/user-info.conf .
        
        zip -0 -r github-to-swamp.zip \
            lambda_function.py \
            github.py \
            user-info.conf \
            requests/ \
            swamp_api/

        if [[ $? -eq 0 ]]; then
            find . -mindepth 1 -type d | xargs rm -rf
            find . ! -name github-to-swamp.zip -delete
        fi

    )
}

main "$@"
