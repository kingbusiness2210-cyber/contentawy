const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

// Pure Node.js PNG Generator
function createPNG(width, height, getPixelRGBA) {
    const buffer = Buffer.alloc(height * (1 + width * 4));
    let offset = 0;

    for (let y = 0; y < height; y++) {
        buffer[offset++] = 0; // Filter type 0 (None)
        for (let x = 0; x < width; x++) {
            const [r, g, b, a] = getPixelRGBA(x, y, width, height);
            buffer[offset++] = Math.min(255, Math.max(0, Math.round(r)));
            buffer[offset++] = Math.min(255, Math.max(0, Math.round(g)));
            buffer[offset++] = Math.min(255, Math.max(0, Math.round(b)));
            buffer[offset++] = Math.min(255, Math.max(0, Math.round(a)));
        }
    }

    const compressed = zlib.deflateSync(buffer);

    function crc32(buf) {
        let c = 0xffffffff;
        for (let i = 0; i < buf.length; i++) {
            c ^= buf[i];
            for (let k = 0; k < 8; k++) {
                c = (c >>> 1) ^ (-(c & 1) & 0xedb88320);
            }
        }
        return (c ^ 0xffffffff) >>> 0;
    }

    function createChunk(type, data) {
        const typeBuf = Buffer.from(type, 'ascii');
        const lenBuf = Buffer.alloc(4);
        lenBuf.writeUInt32BE(data.length, 0);

        const toCrc = Buffer.concat([typeBuf, data]);
        const crcBuf = Buffer.alloc(4);
        crcBuf.writeUInt32BE(crc32(toCrc), 0);

        return Buffer.concat([lenBuf, typeBuf, data, crcBuf]);
    }

    // PNG signature
    const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);

    // IHDR
    const ihdrData = Buffer.alloc(13);
    ihdrData.writeUInt32BE(width, 0);
    ihdrData.writeUInt32BE(height, 4);
    ihdrData[8] = 8; // Bit depth
    ihdrData[9] = 6; // Color type 6 (RGBA)
    ihdrData[10] = 0; // Compression
    ihdrData[11] = 0; // Filter
    ihdrData[12] = 0; // Interlace

    const ihdrChunk = createChunk('IHDR', ihdrData);
    const idatChunk = createChunk('IDAT', compressed);
    const iendChunk = createChunk('IEND', Buffer.alloc(0));

    return Buffer.concat([signature, ihdrChunk, idatChunk, iendChunk]);
}

// Brand Logo Painter for Contentawy (كونتنتاوي)
// Features: Rounded squircle, Modern deep gradient (#1E3A8A -> #2563EB -> #06B6D4),
// Dynamic Growth Arrow / Ascending Bars + 'C' Spark Symbol
function drawBrandIcon(x, y, w, h, isDarkBg = false, isLightBg = false) {
    const nx = (x / w) * 2 - 1; // -1 to 1
    const ny = (y / h) * 2 - 1; // -1 to 1
    const r = Math.sqrt(nx * nx + ny * ny);

    // Squircle distance: (x^4 + y^4)^(1/4)
    const squircleDist = Math.pow(Math.pow(Math.abs(nx), 3.8) + Math.pow(Math.abs(ny), 3.8), 1 / 3.8);

    if (isLightBg) {
        if (squircleDist > 0.95) return [248, 250, 252, 0]; // Transparent outside
    } else {
        if (squircleDist > 0.95) return [11, 17, 32, 0];
    }

    // Anti-aliasing edge
    let edgeAlpha = 255;
    if (squircleDist > 0.91) {
        edgeAlpha = Math.round(255 * (1 - (squircleDist - 0.91) / 0.04));
    }

    // Background Gradient (Electric Blue / Tech Indigo / Mint Accent)
    let bgR, bgG, bgB;
    const gradT = (nx + ny + 2) / 4; // 0 to 1
    bgR = 30 + gradT * (37 - 30);
    bgG = 58 + gradT * (99 - 58);
    bgB = 138 + gradT * (235 - 138);

    // Subtle inner glow / gradient
    const innerGlow = 1.0 - Math.min(1.0, squircleDist * 0.7);
    bgR = Math.min(255, bgR + innerGlow * 20);
    bgG = Math.min(255, bgG + innerGlow * 35);
    bgB = Math.min(255, bgB + innerGlow * 45);

    // Draw Modern Brand Symbol:
    // 1. Sleek C-Arc (Content)
    // 2. Growth Arrow / Bar (Marketing & Conversion ROI)
    const arcDist = Math.abs(r - 0.52);
    const angle = Math.atan2(ny, nx); // -PI to PI
    const inArcAngle = (angle > 0.7 || angle < -0.7); // Open on the right side like a 'C'

    // Bar 1 (Left bar of growth)
    const bar1 = (nx >= -0.32 && nx <= -0.18 && ny >= -0.05 && ny <= 0.35);
    // Bar 2 (Middle bar of growth)
    const bar2 = (nx >= -0.10 && nx <= 0.04 && ny >= -0.25 && ny <= 0.35);
    // Bar 3 (Right bar / Arrow)
    const bar3 = (nx >= 0.12 && nx <= 0.26 && ny >= -0.45 && ny <= 0.35);

    // Arrow Head on top of bar 3
    const arrowX = nx - 0.19;
    const arrowY = ny + 0.55;
    const inArrowHead = (arrowY >= 0 && arrowY <= 0.22 && Math.abs(arrowX) <= (0.22 - arrowY) * 0.9);

    // Outer Modern C-Ring
    const inOuterRing = (arcDist < 0.075 && inArcAngle);

    // Sparkle dot at top right
    const sparkDist = Math.sqrt(Math.pow(nx - 0.45, 2) + Math.pow(ny + 0.45, 2));
    const inSpark = (sparkDist < 0.08);

    if (inOuterRing || inSpark) {
        // Bright Cyan / White Accent
        return [255, 255, 255, edgeAlpha];
    }

    if (inArrowHead || bar3) {
        // Emerald Growth Teal (#10B981)
        return [16, 185, 129, edgeAlpha];
    }

    if (bar2) {
        // Sky Blue (#38BDF8)
        return [56, 189, 248, edgeAlpha];
    }

    if (bar1) {
        // Light Slate Indigo (#818CF8)
        return [129, 140, 248, edgeAlpha];
    }

    return [bgR, bgG, bgB, edgeAlpha];
}

// Generate all target files
const dirs = [
    'assets/icons',
    'assets/images',
    'android/app/src/main/res/mipmap-mdpi',
    'android/app/src/main/res/mipmap-hdpi',
    'android/app/src/main/res/mipmap-xhdpi',
    'android/app/src/main/res/mipmap-xxhdpi',
    'android/app/src/main/res/mipmap-xxxhdpi',
];

dirs.forEach(d => {
    const full = path.join(__dirname, d);
    if (!fs.existsSync(full)) {
        fs.mkdirSync(full, { recursive: true });
    }
});

console.log('Generating Brand Assets & Mipmap Icons for Contentawy...');

// 1. Large App Icons (512x512)
fs.writeFileSync(path.join(__dirname, 'assets/icons/app_icon.png'), createPNG(512, 512, (x, y, w, h) => drawBrandIcon(x, y, w, h, false, false)));
fs.writeFileSync(path.join(__dirname, 'assets/icons/app_icon_dark.png'), createPNG(512, 512, (x, y, w, h) => drawBrandIcon(x, y, w, h, true, false)));
fs.writeFileSync(path.join(__dirname, 'assets/icons/logo_splash.png'), createPNG(512, 512, (x, y, w, h) => drawBrandIcon(x, y, w, h, false, false)));

// 2. Android Mipmap Icons
const mipmaps = [
    { dir: 'mipmap-mdpi', size: 48 },
    { dir: 'mipmap-hdpi', size: 72 },
    { dir: 'mipmap-xhdpi', size: 96 },
    { dir: 'mipmap-xxhdpi', size: 144 },
    { dir: 'mipmap-xxxhdpi', size: 192 },
];

mipmaps.forEach(m => {
    const png = createPNG(m.size, m.size, (x, y, w, h) => drawBrandIcon(x, y, w, h, false, false));
    fs.writeFileSync(path.join(__dirname, `android/app/src/main/res/${m.dir}/ic_launcher.png`), png);
});

console.log('✅ All Brand Assets & Android Launcher Icons generated successfully!');
