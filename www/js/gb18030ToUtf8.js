function parseGb18030Json (response) {
    const decoder = new TextDecoder('gb18030');
    return response.data.arrayBuffer().then((buff) => {
        const u8 = new Uint8Array(buff)
        return JSON.parse(decoder.decode(u8));
    })
} 