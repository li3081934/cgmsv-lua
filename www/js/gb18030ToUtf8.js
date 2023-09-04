function stringToUint8(str) {
    const encoder = new TextEncoder();
    return encoder.encode(str);
}

function blobToString(blob) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => {
            const text = reader.result;
            resolve(text);
        };
        reader.onerror = reject;
        reader.readAsText(blob);
    });
}
function decodeGB18030(buffer) {
    const decoder = new TextDecoder('gb18030');
    return decoder.decode(buffer);
}

function strToUtf8(strArr) {
    return Promise.all(strArr.map((text) => {
        const strUint8 = stringToUint8(text);
        return blobToString(new Blob([decodeGB18030(strUint8)]))
    }))
}