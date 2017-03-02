const THREE = require('three');
const EffectComposer = require('three-effectcomposer')(THREE)

import {PROXY_BUFFER_SIZE} from './proxy_geometry'

export default function Machine(renderer, scene, camera) {
    var composer = new EffectComposer(renderer);

    var m = new THREE.Matrix4();  
    var inverseProj = m.getInverse(camera.projectionMatrix); 
    var n = new THREE.Matrix4();
    var inverseView = m.getInverse(camera.matrixWorldInverse); 
    var alphaTan = Math.tan((camera.fov / 2.0) * 180.0 / Math.PI); 
    var time = new Date(); 

    var shaderPass = new EffectComposer.ShaderPass({
        uniforms: {
            u_buffer: {
                type: '4fv',
                value: undefined
            },
            u_count: {
                type: 'i',
                value: 0
            },
            u_cameraFOV: {
                type: 'f',
                value: camera.fov  
            },
            u_aspect: {
                type: 'f', 
                value: window.innerWidth / window.innerHeight * 1.0
            },
            u_cameraTransf: {
                type: '4m',
                value: camera.matrix 
            },
            u_cameraProjectionInv: {
                type: '4m',
                value: inverseProj
            },
            u_cameraViewInv: {
                type: '4m',
                value: inverseView 
            },
            u_cameraPosition: {
                type: '3fv',
                value: camera.position
            },
            u_alpha: {
                type: 'f',
                value: alphaTan
            },
            u_farClip: {
                type: 'f',
                value: camera.far
            },
            u_time: {
                type: 'f',
                value: time
            }
        },
        vertexShader: require('./glsl/pass-vert.glsl'),
        fragmentShader: require('./glsl/rayMarch-frag.glsl')
    });
    shaderPass.renderToScreen = true;
    composer.addPass(shaderPass);

    return {
        render: function(buffer) {
            shaderPass.material.uniforms.u_buffer.value = buffer;
            shaderPass.material.uniforms.u_count.value = buffer.length / PROXY_BUFFER_SIZE;
            composer.render();
            // update camera 
            camera.updateProjectionMatrix(); 
        }
    }
}