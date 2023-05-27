%% 游戏初始化
clear,clc,close all
global keys;


% 创建游戏窗口
figure('KeyPressFcn', @keyPressed, 'KeyReleaseFcn', @keyReleased);
axis([0 100 0 100]);
axis off;
hold on;

% 创建玩家飞机
player = rectangle('Position', [45 5 5 5], 'FaceColor', 'y');
playerSpeed = 2; % 玩家飞机速度
playerShootRate = 10; % 玩家飞机射击频率，每秒发射几次子弹
playerShootTime = tic; % 玩家上次发射子弹的时间

% 创建敌方飞机
enemies = [];
enemySpeed = 1; % 敌机速度
enemyShootRate = 1.5; % 敌机射击频率，每秒发射几次子弹
enemyShootTime = tic; % 敌机上次发射子弹的时间

% 创建子弹
mybullets = [];
enemybullets = [];

% 创建计分器
blood = 100;
score = 0;
bloodText = text(5, 95, sprintf('Blood: %d', blood), 'FontSize', 10, 'Color', 'k');
scoreText = text(25, 95, sprintf('Blood: %d', score), 'FontSize', 10, 'Color', 'k');

% 定义键盘按键事件
keys = zeros(1, 4); % 上下左右键

%% 游戏循环
while true
    %% 玩家飞机移动
    if keys(1) && player.Position(2) < 90
        player.Position(2) = player.Position(2) + playerSpeed;
    end
    if keys(2) && player.Position(2) > 0
        player.Position(2) = player.Position(2) - playerSpeed;
    end
    if keys(3) && player.Position(1) > 0
        player.Position(1) = player.Position(1) - playerSpeed;
    end
    if keys(4) && player.Position(1) < 90
        player.Position(1) = player.Position(1) + playerSpeed;
    end
    
    %% 玩家飞机射击
    if toc(playerShootTime) > 1/playerShootRate
        playerShootTime = tic;
        bullet = rectangle('Position', [player.Position(1)+4 player.Position(2)+10 1 1], 'FaceColor', 'b');
        mybullets = [mybullets bullet];
    end
    
    %% 敌机产生
    randData = rand;
    enemyRate = 0.1;
    if randData < enemyRate
        if randData < enemyRate*0.4
            enemy = rectangle('Position', [rand()*100 100 5 5], 'FaceColor', 'r');
        elseif randData < enemyRate*0.8
            enemy = rectangle('Position', [rand()*100 100 5 5], 'FaceColor', 'g');
        else
            enemy = rectangle('Position', [rand()*100 100 5 5], 'FaceColor', 'b');
        end
        enemies = [enemies enemy];
    end
    
    % 敌机移动和清除
    enemyDelNum = 0;
    for ii = 1:length(enemies)        
        enemyIdx = ii - enemyDelNum;
        enemies(enemyIdx).Position(2) = enemies(enemyIdx).Position(2) - enemySpeed;

        if enemies(enemyIdx).FaceColor(1) == 1
            enemies(enemyIdx).Position(1) = enemies(enemyIdx).Position(1) - enemySpeed/4;
        elseif enemies(enemyIdx).FaceColor(2) == 1
            enemies(enemyIdx).Position(1) = enemies(enemyIdx).Position(1) + enemySpeed/8;
        end

        if enemies(enemyIdx).Position(2) < 0 || enemies(enemyIdx).Position(1) < 0 || ...
                enemies(enemyIdx).Position(1) > 100
            delete(enemies(enemyIdx));
            enemies(enemyIdx) = [];
            enemyDelNum = enemyDelNum + 1;
        end
    end

    % 敌我双方飞机碰撞检测
    enemyDelNum = 0;
    for ii = 1:length(enemies) 
        enemyIdx = ii - enemyDelNum;
        if rectint(player.Position,enemies(enemyIdx).Position) > 0
            delete(enemies(enemyIdx));
            enemies(enemyIdx) = [];
            blood = blood -20;
            enemyDelNum = enemyDelNum + 1;
        end
    end

    % 敌机射击
    if toc(enemyShootTime) > 1/enemyShootRate
        for i = 1:length(enemies)            
            if rand < 0.8
                if mod(i,3) == 0
                    bullet = rectangle('Position', [enemies(i).Position(1)-2 enemies(i).Position(2) 1 1], 'FaceColor', 'y');
                elseif mod(i,3) == 1
                    bullet = rectangle('Position', [enemies(i).Position(1)-2 enemies(i).Position(2) 1 1], 'FaceColor', 'g');
                else
                    bullet = rectangle('Position', [enemies(i).Position(1)-2 enemies(i).Position(2) 1 1], 'FaceColor', 'r');
                end
                enemybullets = [enemybullets bullet];
            end
        end
        enemyShootTime = tic;
    end

    % 我方子弹移动和碰撞检测
    myDelBullets = 0;
    for i=1:length(mybullets)
        myBulletsIdx = i-myDelBullets;
        mybullets(myBulletsIdx).Position(2) = mybullets(myBulletsIdx).Position(2) + 2;        

        for j = 1:length(enemies)
            if rectint(mybullets(myBulletsIdx).Position, enemies(j).Position) > 0
%                 blood = blood + 1;
                score = score + 1;
                delete(mybullets(myBulletsIdx));
                delete(enemies(j));
                mybullets(myBulletsIdx) = [];
                enemies(j) = [];
                bloodText.String = sprintf('Blood: %d', blood);
                scoreText.String = sprintf('Score: %d', score);
                myDelBullets = myDelBullets + 1;
                break;
            end
        end        
    end
    %我方子弹清除
    myDelBullets2 = 0;
    for ii=1:length(mybullets)
        myBulletsIdx = ii - myDelBullets2;
        if mybullets(myBulletsIdx).Position(2) > 100
            delete(mybullets(myBulletsIdx));
            mybullets(myBulletsIdx) = [];
            myDelBullets2 = myDelBullets2 + 1;
        end
    end

    % 敌方子弹移动和碰撞检测
    enemyDelBullets = 0;
    for i = 1:length(enemybullets)        
        enemyBulletsIdx = i-enemyDelBullets;
        enemybullets(enemyBulletsIdx).Position(2) = enemybullets(enemyBulletsIdx).Position(2) - 2;

        if enemybullets(enemyBulletsIdx).FaceColor(1) == 1 && ...
                enemybullets(enemyBulletsIdx).FaceColor(2) == 0
            enemybullets(enemyBulletsIdx).Position(1) = enemybullets(enemyBulletsIdx).Position(1) + 1;
        elseif enemybullets(enemyBulletsIdx).FaceColor(1) == 0 && ...
                enemybullets(enemyBulletsIdx).FaceColor(2) == 1
            enemybullets(enemyBulletsIdx).Position(1) = enemybullets(enemyBulletsIdx).Position(1) - 1;
        end

        if rectint(enemybullets(enemyBulletsIdx).Position, player.Position) > 0
            delete(enemybullets(enemyBulletsIdx));
            enemybullets(enemyBulletsIdx) = [];
            enemyDelBullets = enemyDelBullets + 1;
            blood = blood - 10;
            
            if blood < 0
                bloodText.String = sprintf('Blood: %d', 0);
                break;
            else
                bloodText.String = sprintf('Blood: %d', blood);
            end
        end
    end
    %敌方子弹清除
    enemyDelBullets2 = 0;
    for ii=1:length(enemybullets)
        enemyBulletsIdx = ii - enemyDelBullets2;
        if enemybullets(enemyBulletsIdx).Position(1) < 0 || enemybullets(enemyBulletsIdx).Position(2) < 0
            delete(enemybullets(enemyBulletsIdx));
            enemybullets(enemyBulletsIdx) = [];
            enemyDelBullets2 = enemyDelBullets2 + 1;
        end
    end    
    
    %% 游戏结束
    if blood < 0 || score > 100
        break;
    end
    
    %% 暂停一段时间
    pause(0.02);
end

%% 游戏结束
if blood < 0
    text(50, 50, 'Game Over!', 'FontSize', 20, 'Color', 'r', 'HorizontalAlignment', 'center');
else
    text(50, 50, 'Game Pass!', 'FontSize', 20, 'Color', 'r', 'HorizontalAlignment', 'center');
end

function keyPressed(~, event)
    global keys;
    key = event.Key;
    if strcmp(key, 'uparrow')
        keys(1) = 1;
    elseif strcmp(key, 'downarrow')
        keys(2) = 1;
    elseif strcmp(key, 'leftarrow')
        keys(3) = 1;
    elseif strcmp(key, 'rightarrow')
        keys(4) = 1;
    end
end

function keyReleased(~, event)
    global keys;
    key = event.Key;
    if strcmp(key, 'uparrow')
        keys(1) = 0;
    elseif strcmp(key, 'downarrow')
        keys(2) = 0;
    elseif strcmp(key, 'leftarrow')
        keys(3) = 0;
    elseif strcmp(key, 'rightarrow')
        keys(4) = 0;
    end
end

